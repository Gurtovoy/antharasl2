/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.eclipse.jdt.internal.compiler.tool.EclipseCompiler
 *  org.eclipse.jdt.internal.compiler.tool.EclipseFileManager
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.commons.compiler;

import java.io.File;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Locale;
import javax.tools.Diagnostic;
import javax.tools.DiagnosticListener;
import javax.tools.JavaCompiler;
import javax.tools.JavaFileObject;
import javax.tools.StandardJavaFileManager;
import l2s.commons.compiler.MemoryClassLoader;
import l2s.commons.compiler.MemoryJavaFileManager;
import org.eclipse.jdt.internal.compiler.tool.EclipseCompiler;
import org.eclipse.jdt.internal.compiler.tool.EclipseFileManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Compiler {
    private static final Logger _log = LoggerFactory.getLogger(Compiler.class);
    private static final JavaCompiler javac = new EclipseCompiler();
    private final DiagnosticListener<JavaFileObject> listener = new DefaultDiagnosticListener();
    private final StandardJavaFileManager fileManager = new EclipseFileManager(Locale.getDefault(), Charset.defaultCharset());
    private final MemoryClassLoader memClassLoader = new MemoryClassLoader();
    private final MemoryJavaFileManager memFileManager = new MemoryJavaFileManager(this.fileManager, this.memClassLoader);

    public boolean compile(File ... files) {
        ArrayList<String> options = new ArrayList<String>();
        options.add("-Xlint:all");
        options.add("-warn:none");
        options.add("-g");
        options.add("-17");
        StringWriter writer = new StringWriter();
        JavaCompiler.CompilationTask compile = javac.getTask(writer, this.memFileManager, this.listener, options, null, this.fileManager.getJavaFileObjects(files));
        return compile.call() != false;
    }

    public boolean compile(Collection<File> files) {
        return this.compile(files.toArray(new File[files.size()]));
    }

    public MemoryClassLoader getClassLoader() {
        return this.memClassLoader;
    }

    private class DefaultDiagnosticListener
    implements DiagnosticListener<JavaFileObject> {
        private DefaultDiagnosticListener() {
        }

        @Override
        public void report(Diagnostic<? extends JavaFileObject> diagnostic) {
            _log.error(diagnostic.getSource().getName() + (diagnostic.getPosition() == -1L ? "" : ":" + diagnostic.getLineNumber() + "," + diagnostic.getColumnNumber()) + ": " + diagnostic.getMessage(Locale.getDefault()));
        }
    }
}

