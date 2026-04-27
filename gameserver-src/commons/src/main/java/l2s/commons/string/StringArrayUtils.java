/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.commons.string;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class StringArrayUtils {
    private static final Logger _log = LoggerFactory.getLogger(StringArrayUtils.class);

    public static int[] stringToIntArray(String text, String separator) {
        if (text == null || text.isEmpty()) {
            return new int[0];
        }
        String[] separatedText = text.split(separator);
        int[] result = new int[separatedText.length];
        try {
            for (int i = 0; i < separatedText.length; ++i) {
                result[i] = Integer.parseInt(separatedText[i]);
            }
        }
        catch (NumberFormatException e) {
            _log.error("StringArrayUtils: Error while convert string to int array.", (Throwable)e);
            return new int[0];
        }
        return result;
    }

    public static int[][] stringToIntArray2X(String text, String separator1, String separator2) {
        if (text == null || text.isEmpty()) {
            return new int[0][];
        }
        String[] separatedText = text.split(separator1);
        int[][] result = new int[separatedText.length][];
        for (int i = 0; i < separatedText.length; ++i) {
            result[i] = StringArrayUtils.stringToIntArray(separatedText[i], separator2);
        }
        return result;
    }

    public static long[] stringToLongArray(String text, String separator) {
        if (text == null || text.isEmpty()) {
            return new long[0];
        }
        String[] separatedText = text.split(separator);
        long[] result = new long[separatedText.length];
        try {
            for (int i = 0; i < separatedText.length; ++i) {
                result[i] = Long.parseLong(separatedText[i]);
            }
        }
        catch (NumberFormatException e) {
            _log.error("StringArrayUtils: Error while convert string to long array.", (Throwable)e);
            return new long[0];
        }
        return result;
    }

    public static long[][] stringToLong2X(String text, String separator1, String separator2) {
        if (text == null || text.isEmpty()) {
            return new long[0][];
        }
        String[] separatedText = text.split(separator1);
        long[][] result = new long[separatedText.length][];
        for (int i = 0; i < separatedText.length; ++i) {
            result[i] = StringArrayUtils.stringToLongArray(separatedText[i], separator2);
        }
        return result;
    }

    public static double[] stringToDoubleArray(String text, String separator) {
        if (text == null || text.isEmpty()) {
            return new double[0];
        }
        String[] separatedText = text.split(separator);
        double[] result = new double[separatedText.length];
        try {
            for (int i = 0; i < separatedText.length; ++i) {
                result[i] = Double.parseDouble(separatedText[i]);
            }
        }
        catch (NumberFormatException e) {
            _log.error("StringArrayUtils: Error while convert string to double array.", (Throwable)e);
            return new double[0];
        }
        return result;
    }

    public static double[][] stringToDouble2X(String text, String separator1, String separator2) {
        if (text == null || text.isEmpty()) {
            return new double[0][];
        }
        String[] separatedText = text.split(separator1);
        double[][] result = new double[separatedText.length][];
        for (int i = 0; i < separatedText.length; ++i) {
            result[i] = StringArrayUtils.stringToDoubleArray(separatedText[i], separator2);
        }
        return result;
    }
}

