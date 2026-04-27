/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.compiler.Compiler
 *  l2s.commons.compiler.MemoryClassLoader
 *  l2s.commons.listener.Listener
 *  l2s.commons.listener.ListenerList
 *  org.apache.commons.io.FileUtils
 *  org.apache.commons.io.filefilter.FileFilterUtils
 *  org.apache.commons.io.filefilter.IOFileFilter
 *  org.apache.commons.lang3.ClassUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.scripts;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.jar.JarEntry;
import java.util.jar.JarInputStream;
import java.util.zip.ZipInputStream;
import l2s.commons.compiler.Compiler;
import l2s.commons.compiler.MemoryClassLoader;
import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.gameserver.Config;
import l2s.gameserver.handler.bypass.Bypass;
import l2s.gameserver.handler.bypass.BypassHolder;
import l2s.gameserver.listener.script.OnInitScriptListener;
import l2s.gameserver.listener.script.OnLoadScriptListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.scripts.annotation.OnScriptInit;
import l2s.gameserver.scripts.annotation.OnScriptLoad;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.lang3.ClassUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Scripts {
    private static final Logger _log = LoggerFactory.getLogger(Scripts.class);
    private static final Scripts _instance = new Scripts();
    private final Map<String, Class<?>> _classes = new TreeMap();
    private final Map<Class<?>, Object> _instances = new ConcurrentHashMap();
    private final ScriptListenerImpl _listeners = new ScriptListenerImpl();

    public static Scripts getInstance() {
        return _instance;
    }

    private Scripts() {
        this.load();
    }

    private void load() {
        _log.info("Scripts: Loading...");
        List<Class<?>> classes = this.load(new File(Config.DATAPACK_ROOT, "data/scripts"));
        if (classes.isEmpty()) {
            throw new Error("Failed loading scripts!");
        }
        for (Class<?> clazz : classes) {
            this._classes.put(clazz.getName(), clazz);
        }
        File f = new File("./lib/scripts.jar");
        if (f.exists()) {
            _log.info("Scripts: Loading library...");
            ZipInputStream stream = null;
            try {
                stream = new JarInputStream(new FileInputStream(f));
                JarEntry entry = null;
                while ((entry = ((JarInputStream)stream).getNextJarEntry()) != null) {
                    Class<?> clazz;
                    String name;
                    if (entry.getName().contains(ClassUtils.INNER_CLASS_SEPARATOR) || !entry.getName().endsWith(".class") || this._classes.containsKey(name = entry.getName().replace(".class", "").replace("/", ".")) || Modifier.isAbstract((clazz = this.getClass().getClassLoader().loadClass(name)).getModifiers())) continue;
                    this._classes.put(clazz.getName(), clazz);
                }
            }
            catch (Exception e) {
                throw new Error("Failed loading scripts library!");
            }
            finally {
                try {
                    if (stream != null) {
                        stream.close();
                    }
                }
                catch (IOException ioe) {}
            }
        }
        _log.info("Scripts: Loaded " + this._classes.size() + " classes.");
        for (Class<?> clazz : this._classes.values()) {
            try {
                Object o = this.getClassInstance(clazz);
                if (ClassUtils.isAssignable(clazz, OnLoadScriptListener.class)) {
                    if (o == null) {
                        o = clazz.newInstance();
                    }
                    this._listeners.add((OnLoadScriptListener)o);
                }
                for (Method method : clazz.getMethods()) {
                    if (!method.isAnnotationPresent(OnScriptLoad.class)) continue;
                    Class<?>[] par = method.getParameterTypes();
                    if (par.length != 0) {
                        _log.error("Wrong parameters for load method: " + method.getName() + ", class: " + clazz.getSimpleName());
                        continue;
                    }
                    try {
                        if (Modifier.isStatic(method.getModifiers())) {
                            method.invoke(clazz, new Object[0]);
                            continue;
                        }
                        if (o == null) {
                            o = clazz.newInstance();
                        }
                        method.invoke(o, new Object[0]);
                    }
                    catch (Exception e) {
                        _log.error("Exception: " + e, (Throwable)e);
                    }
                }
            }
            catch (Exception e) {
                _log.error("", (Throwable)e);
            }
        }
        this._listeners.load();
    }

    public void init() {
        for (Class<?> clazz : this._classes.values()) {
            this.init(clazz);
        }
        this._listeners.init();
    }

    public List<Class<?>> load(File target) {
        Collection<File> scriptFiles = Collections.emptyList();
        if (target.isFile()) {
            scriptFiles = new ArrayList<File>(1);
            scriptFiles.add(target);
        } else if (target.isDirectory()) {
            scriptFiles = FileUtils.listFiles((File)target, (IOFileFilter)FileFilterUtils.suffixFileFilter((String)".java"), (IOFileFilter)FileFilterUtils.directoryFileFilter());
        }
        if (scriptFiles.isEmpty()) {
            return Collections.emptyList();
        }
        ArrayList classes = new ArrayList();
        Compiler compiler = new Compiler();
        if (compiler.compile(scriptFiles)) {
            MemoryClassLoader classLoader = compiler.getClassLoader();
            for (String name : classLoader.getLoadedClasses()) {
                if (name.contains(ClassUtils.INNER_CLASS_SEPARATOR)) continue;
                try {
                    Class clazz = classLoader.loadClass(name);
                    if (Modifier.isAbstract(clazz.getModifiers())) continue;
                    classes.add(clazz);
                }
                catch (ClassNotFoundException e) {
                    _log.error("Scripts: Can't load script class: " + name, (Throwable)e);
                    classes.clear();
                    break;
                }
            }
        }
        return classes;
    }

    private Object init(Class<?> clazz) {
        Object o = this.getClassInstance(clazz);
        try {
            if (ClassUtils.isAssignable(clazz, OnInitScriptListener.class)) {
                if (o == null) {
                    o = clazz.newInstance();
                }
                this._listeners.add((OnInitScriptListener)o);
            }
            for (Method method : clazz.getMethods()) {
                Class<?>[] par;
                if (method.isAnnotationPresent(Bypass.class)) {
                    par = method.getParameterTypes();
                    if (par.length == 0 || par[0] != Player.class || par[1] != NpcInstance.class || par[2] != String[].class) {
                        _log.error("Wrong parameters for bypass method: " + method.getName() + ", class: " + clazz.getSimpleName());
                        continue;
                    }
                    Bypass an = method.getAnnotation(Bypass.class);
                    if (Modifier.isStatic(method.getModifiers())) {
                        BypassHolder.getInstance().registerBypass(an.value(), clazz, method);
                        continue;
                    }
                    if (o == null) {
                        o = clazz.newInstance();
                    }
                    BypassHolder.getInstance().registerBypass(an.value(), o, method);
                    continue;
                }
                if (!method.isAnnotationPresent(OnScriptInit.class)) continue;
                par = method.getParameterTypes();
                if (par.length != 0) {
                    _log.error("Wrong parameters for init method: " + method.getName() + ", class: " + clazz.getSimpleName());
                    continue;
                }
                try {
                    if (Modifier.isStatic(method.getModifiers())) {
                        method.invoke(clazz, new Object[0]);
                        continue;
                    }
                    if (o == null) {
                        o = clazz.newInstance();
                    }
                    method.invoke(o, new Object[0]);
                }
                catch (Exception e) {
                    _log.error("Exception: " + e, (Throwable)e);
                }
            }
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
        return o;
    }

    public Map<String, Class<?>> getClasses() {
        return this._classes;
    }

    public Object getClassInstance(Class<?> clazz) {
        return this._instances.get(clazz);
    }

    public Object getClassInstance(String className) {
        Class<?> clazz = this._classes.get(className);
        if (clazz != null) {
            return this.getClassInstance(clazz);
        }
        return null;
    }

    public class ScriptListenerImpl
    extends ListenerList<Scripts> {
        public void load() {
            for (Listener listener : this.getListeners()) {
                if (!OnLoadScriptListener.class.isInstance(listener)) continue;
                ((OnLoadScriptListener)listener).onLoad();
            }
        }

        public void init() {
            for (Listener listener : this.getListeners()) {
                if (!OnInitScriptListener.class.isInstance(listener)) continue;
                ((OnInitScriptListener)listener).onInit();
            }
        }
    }
}

