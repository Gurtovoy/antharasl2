/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.compiler;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.compiler.MemoryByteCode;

public class MemoryClassLoader
extends ClassLoader {
    private final Map<String, MemoryByteCode> classes = new HashMap<String, MemoryByteCode>();
    private final Map<String, MemoryByteCode> loaded = new HashMap<String, MemoryByteCode>();

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        MemoryByteCode mbc = this.classes.get(name);
        if (mbc == null && (mbc = this.classes.get(name)) == null) {
            return super.findClass(name);
        }
        return this.defineClass(name, mbc.getBytes(), 0, mbc.getBytes().length);
    }

    public void addClass(MemoryByteCode mbc) {
        this.classes.put(mbc.getName(), mbc);
        this.loaded.put(mbc.getName(), mbc);
    }

    public MemoryByteCode getClass(String name) {
        return this.classes.get(name);
    }

    public String[] getLoadedClasses() {
        return this.loaded.keySet().toArray(new String[this.loaded.size()]);
    }

    public void clear() {
        this.classes.clear();
        this.loaded.clear();
    }
}

