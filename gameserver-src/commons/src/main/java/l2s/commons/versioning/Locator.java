/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.versioning;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.StringCharacterIterator;
import java.util.Locale;

public final class Locator {
    private Locator() {
    }

    public static File getClassSource(Class<?> c) {
        String classResource = c.getName().replace('.', '/') + ".class";
        return Locator.getResourceSource(c.getClassLoader(), classResource);
    }

    public static File getResourceSource(ClassLoader c, String resource) {
        if (c == null) {
            c = Locator.class.getClassLoader();
        }
        URL url = null;
        url = c == null ? ClassLoader.getSystemResource(resource) : c.getResource(resource);
        if (url != null) {
            String u = url.toString();
            if (u.startsWith("jar:file:")) {
                int pling = u.indexOf("!");
                String jarName = u.substring(4, pling);
                return new File(Locator.fromURI(jarName));
            }
            if (u.startsWith("file:")) {
                int tail = u.indexOf(resource);
                String dirName = u.substring(0, tail);
                return new File(Locator.fromURI(dirName));
            }
        }
        return null;
    }

    public static String fromURI(String uri) {
        String file;
        int queryPos;
        URL url = null;
        try {
            url = new URL(uri);
        }
        catch (MalformedURLException emYouEarlEx) {
            // empty catch block
        }
        if (url == null || !"file".equals(url.getProtocol())) {
            throw new IllegalArgumentException("Can only handle valid file: URIs");
        }
        StringBuilder buf = new StringBuilder(url.getHost());
        if (buf.length() > 0) {
            buf.insert(0, File.separatorChar).insert(0, File.separatorChar);
        }
        buf.append((queryPos = (file = url.getFile()).indexOf(63)) < 0 ? file : file.substring(0, queryPos));
        uri = buf.toString().replace('/', File.separatorChar);
        if (File.pathSeparatorChar == ';' && uri.startsWith("\\") && uri.length() > 2 && Character.isLetter(uri.charAt(1)) && uri.lastIndexOf(58) > -1) {
            uri = uri.substring(1);
        }
        String path = Locator.decodeUri(uri);
        return path;
    }

    private static String decodeUri(String uri) {
        if (uri.indexOf(37) == -1) {
            return uri;
        }
        StringBuilder sb = new StringBuilder();
        StringCharacterIterator iter = new StringCharacterIterator(uri);
        char c = iter.first();
        while (c != '\uffff') {
            if (c == '%') {
                char c1 = iter.next();
                if (c1 != '\uffff') {
                    int i1 = Character.digit(c1, 16);
                    char c2 = iter.next();
                    if (c2 != '\uffff') {
                        int i2 = Character.digit(c2, 16);
                        sb.append((char)((i1 << 4) + i2));
                    }
                }
            } else {
                sb.append(c);
            }
            c = iter.next();
        }
        String path = sb.toString();
        return path;
    }

    public static File getToolsJar() {
        File toolsJar;
        boolean toolsJarAvailable = false;
        try {
            Class.forName("com.sun.tools.javac.Main");
            toolsJarAvailable = true;
        }
        catch (Exception e) {
            try {
                Class.forName("sun.tools.javac.Main");
                toolsJarAvailable = true;
            }
            catch (Exception e2) {
                // empty catch block
            }
        }
        if (toolsJarAvailable) {
            return null;
        }
        String javaHome = System.getProperty("java.home");
        if (javaHome.toLowerCase(Locale.US).endsWith("jre")) {
            javaHome = javaHome.substring(0, javaHome.length() - 4);
        }
        if (!(toolsJar = new File(javaHome + "/lib/tools.jar")).exists()) {
            System.out.println("Unable to locate tools.jar. Expected to find it in " + toolsJar.getPath());
            return null;
        }
        return toolsJar;
    }

    public static URL[] getLocationURLs(File location) throws MalformedURLException {
        return Locator.getLocationURLs(location, new String[]{".jar"});
    }

    public static URL[] getLocationURLs(File location, String[] extensions) throws MalformedURLException {
        URL[] urls = new URL[]{};
        if (!location.exists()) {
            return urls;
        }
        if (!location.isDirectory()) {
            urls = new URL[1];
            String path = location.getPath();
            for (int i = 0; i < extensions.length; ++i) {
                if (!path.toLowerCase().endsWith(extensions[i])) continue;
                urls[0] = location.toURI().toURL();
                break;
            }
            return urls;
        }
        File[] matches = location.listFiles((dir, name) -> {
            for (int i = 0; i < extensions.length; ++i) {
                if (!name.toLowerCase().endsWith(extensions[i])) continue;
                return true;
            }
            return false;
        });
        urls = new URL[matches.length];
        for (int i = 0; i < matches.length; ++i) {
            urls[i] = matches[i].toURI().toURL();
        }
        return urls;
    }
}

