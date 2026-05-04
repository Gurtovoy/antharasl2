package l2s.commons.compiler;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.net.URI;
import javax.tools.JavaFileObject;
import javax.tools.SimpleJavaFileObject;

public class MemoryByteCode
extends SimpleJavaFileObject {
    private ByteArrayOutputStream oStream;
    private final String className;

    public MemoryByteCode(String className, URI uri) {
        super(uri, JavaFileObject.Kind.CLASS);
        this.className = className;
    }

    @Override
    public OutputStream openOutputStream() {
        this.oStream = new ByteArrayOutputStream();
        return this.oStream;
    }

    public byte[] getBytes() {
        return this.oStream.toByteArray();
    }

    @Override
    public String getName() {
        return this.className;
    }
}

