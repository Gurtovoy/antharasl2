/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.mozilla.universalchardet.UniversalDetector
 */
package l2s.commons.string;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import org.mozilla.universalchardet.UniversalDetector;

public class CharsetEncodingDetector {
    private static final UniversalDetector DETECTOR = new UniversalDetector(null);
    private static final String DEFAULT_ENCODING = "UTF-8";

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static String detectEncoding(File file) throws IOException {
        FileInputStream fis = null;
        try {
            int nread;
            fis = new FileInputStream(file);
            byte[] buf = new byte[4096];
            while ((nread = fis.read(buf)) > 0 && !DETECTOR.isDone()) {
                DETECTOR.handleData(buf, 0, nread);
            }
            DETECTOR.dataEnd();
            String encoding = DETECTOR.getDetectedCharset();
            DETECTOR.reset();
            String string = encoding;
            return string;
        }
        catch (Exception e) {
            String string = DEFAULT_ENCODING;
            return string;
        }
        finally {
            try {
                if (fis != null) {
                    fis.close();
                }
            }
            catch (IOException ioe) {}
        }
    }
}

