package l2s.commons.compiler;

import java.io.IOException;
import java.net.URI;
import javax.tools.FileObject;
import javax.tools.ForwardingJavaFileManager;
import javax.tools.JavaFileManager;
import javax.tools.JavaFileObject;
import javax.tools.StandardJavaFileManager;
import l2s.commons.compiler.MemoryByteCode;
import l2s.commons.compiler.MemoryClassLoader;

public class MemoryJavaFileManager
extends ForwardingJavaFileManager<StandardJavaFileManager> {
    private MemoryClassLoader cl;

    public MemoryJavaFileManager(StandardJavaFileManager sjfm, MemoryClassLoader xcl) {
        super(sjfm);
        this.cl = xcl;
    }

    @Override
    public JavaFileObject getJavaFileForOutput(JavaFileManager.Location location, String className, JavaFileObject.Kind kind, FileObject sibling) throws IOException {
        MemoryByteCode mbc = new MemoryByteCode(className.replace('/', '.').replace('\\', '.'), URI.create("file:///" + className.replace('.', '/').replace('\\', '/') + kind.extension));
        this.cl.addClass(mbc);
        return mbc;
    }

    @Override
    public ClassLoader getClassLoader(JavaFileManager.Location location) {
        return this.cl;
    }
}

