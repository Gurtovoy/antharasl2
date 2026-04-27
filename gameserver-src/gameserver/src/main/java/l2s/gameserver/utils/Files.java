/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.string.CharsetEncodingDetector
 *  org.apache.commons.io.FileUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.utils;

import java.io.File;
import java.io.IOException;
import l2s.commons.string.CharsetEncodingDetector;
import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Files {
    private static final Logger _log = LoggerFactory.getLogger(Files.class);

    public static String readFile(File file, String outputEncode) throws IOException {
        String content = FileUtils.readFileToString((File)file, (String)CharsetEncodingDetector.detectEncoding((File)file));
        content = new String(content.getBytes(outputEncode));
        return content;
    }

    public static String readFile(File file) throws IOException {
        return Files.readFile(file, "UTF-8");
    }

    public static void writeFile(String path, String string) {
        try {
            FileUtils.writeStringToFile((File)new File(path), (String)string, (String)"UTF-8");
        }
        catch (IOException e) {
            _log.error("Error while saving file : " + path, (Throwable)e);
        }
    }

    public static boolean copyFile(String srcFile, String destFile) {
        try {
            FileUtils.copyFile((File)new File(srcFile), (File)new File(destFile), (boolean)false);
            return true;
        }
        catch (IOException e) {
            _log.error("Error while copying file : " + srcFile + " to " + destFile, (Throwable)e);
            return false;
        }
    }
}

