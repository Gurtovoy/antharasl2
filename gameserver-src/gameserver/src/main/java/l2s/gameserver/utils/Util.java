/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.utils;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;
import l2s.commons.annotations.Nullable;
import l2s.commons.util.Rnd;
import l2s.gameserver.data.htm.HtmTemplates;
import l2s.gameserver.utils.Language;
import l2s.gameserver.utils.Strings;

public class Util {
    static final String PATTERN = "0.0000000000E00";
    static final DecimalFormat df;
    private static NumberFormat adenaFormatter;
    private static Pattern _pattern;

    public static boolean isMatchingRegexp(String text, String template) {
        Pattern pattern = null;
        try {
            pattern = Pattern.compile(template);
        }
        catch (PatternSyntaxException e) {
            e.printStackTrace();
        }
        if (pattern == null) {
            return false;
        }
        Matcher regexp = pattern.matcher(text);
        return regexp.matches();
    }

    public static String formatDouble(double x, String nanString, boolean forceExponents) {
        if (Double.isNaN(x)) {
            return nanString;
        }
        if (forceExponents) {
            return df.format(x);
        }
        if ((double)((long)x) == x) {
            return String.valueOf((long)x);
        }
        return String.valueOf(x);
    }

    public static String formatAdena(long amount) {
        return adenaFormatter.format(amount);
    }

    public static String formatTime(int time) {
        if (time == 0) {
            return "now";
        }
        time = Math.abs(time);
        String ret = "";
        long numDays = time / 86400;
        time = (int)((long)time - numDays * 86400L);
        long numHours = time / 3600;
        time = (int)((long)time - numHours * 3600L);
        long numMins = time / 60;
        time = (int)((long)time - numMins * 60L);
        long numSeconds = time;
        if (numDays > 0L) {
            ret = ret + numDays + "d ";
        }
        if (numHours > 0L) {
            ret = ret + numHours + "h ";
        }
        if (numMins > 0L) {
            ret = ret + numMins + "m ";
        }
        if (numSeconds > 0L) {
            ret = ret + numSeconds + "s";
        }
        return ret.trim();
    }

    public static long rollDrop(long min, long max, double calcChance, double rate) {
        if (calcChance <= 0.0 || min <= 0L || max <= 0L) {
            return 0L;
        }
        int dropmult = 1;
        if ((calcChance *= rate) > 1000000.0) {
            if (calcChance % 1000000.0 == 0.0) {
                dropmult = (int)(calcChance / 1000000.0);
            } else {
                dropmult = (int)Math.ceil(calcChance / 1000000.0);
                calcChance /= (double)dropmult;
            }
        }
        return Rnd.chance((double)(calcChance / 10000.0)) ? Rnd.get((long)(min * (long)dropmult), (long)(max * (long)dropmult)) : 0L;
    }

    public static int packInt(int[] a, int bits) throws Exception {
        int m = 32 / bits;
        if (a.length > m) {
            throw new Exception("Overflow");
        }
        int result = 0;
        int mval = (int)Math.pow(2.0, bits);
        for (int i = 0; i < m; ++i) {
            int next;
            result <<= bits;
            if (a.length > i) {
                next = a[i];
                if (next >= mval || next < 0) {
                    throw new Exception("Overload, value is out of range");
                }
            } else {
                next = 0;
            }
            result += next;
        }
        return result;
    }

    public static long packLong(int[] a, int bits) throws Exception {
        int m = 64 / bits;
        if (a.length > m) {
            throw new Exception("Overflow");
        }
        long result = 0L;
        int mval = (int)Math.pow(2.0, bits);
        for (int i = 0; i < m; ++i) {
            int next;
            result <<= bits;
            if (a.length > i) {
                next = a[i];
                if (next >= mval || next < 0) {
                    throw new Exception("Overload, value is out of range");
                }
            } else {
                next = 0;
            }
            result += (long)next;
        }
        return result;
    }

    public static int[] unpackInt(int a, int bits) {
        int m = 32 / bits;
        int mval = (int)Math.pow(2.0, bits);
        int[] result = new int[m];
        for (int i = m; i > 0; --i) {
            int next = a;
            result[i - 1] = next - (a >>= bits) * mval;
        }
        return result;
    }

    public static int[] unpackLong(long a, int bits) {
        int m = 64 / bits;
        int mval = (int)Math.pow(2.0, bits);
        int[] result = new int[m];
        for (int i = m; i > 0; --i) {
            long next = a;
            result[i - 1] = (int)(next - (a >>= bits) * (long)mval);
        }
        return result;
    }

    public static float[] parseCommaSeparatedFloatArray(String s) {
        if (s.isEmpty()) {
            return new float[0];
        }
        String[] tmp = s.replaceAll(",", ";").replaceAll("\\n", ";").split(";");
        float[] val = new float[tmp.length];
        for (int i = 0; i < tmp.length; ++i) {
            val[i] = Float.parseFloat(tmp[i]);
        }
        return val;
    }

    public static int[] parseCommaSeparatedIntegerArray(String s) {
        if (s.isEmpty()) {
            return new int[0];
        }
        String[] tmp = s.replaceAll(",", ";").replaceAll("\\n", ";").split(";");
        int[] val = new int[tmp.length];
        for (int i = 0; i < tmp.length; ++i) {
            val[i] = Integer.parseInt(tmp[i]);
        }
        return val;
    }

    public static long[] parseCommaSeparatedLongArray(String s) {
        if (s.isEmpty()) {
            return new long[0];
        }
        String[] tmp = s.replaceAll(",", ";").replaceAll("\\n", ";").split(";");
        long[] val = new long[tmp.length];
        for (int i = 0; i < tmp.length; ++i) {
            val[i] = Long.parseLong(tmp[i]);
        }
        return val;
    }

    public static long[][] parseStringForDoubleArray(String s) {
        String[] temp = s.replaceAll("\\n", ";").split(";");
        long[][] val = new long[temp.length][];
        for (int i = 0; i < temp.length; ++i) {
            val[i] = Util.parseCommaSeparatedLongArray(temp[i]);
        }
        return val;
    }

    public static String joinStrings(String glueStr, String[] strings, int startIdx, int maxCount) {
        return Strings.joinStrings(glueStr, strings, startIdx, maxCount);
    }

    public static String joinStrings(String glueStr, String[] strings, int startIdx) {
        return Strings.joinStrings(glueStr, strings, startIdx, -1);
    }

    public static boolean isNumber(String s) {
        try {
            Double.parseDouble(s);
        }
        catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    public static String dumpObject(Object o, boolean simpleTypes, boolean parentFields, boolean ignoreStatics) {
        Class<?> cls = o.getClass();
        String result = "[" + (simpleTypes ? cls.getSimpleName() : cls.getName()) + "\n";
        ArrayList<Field> fields = new ArrayList<Field>();
        for (cls = o.getClass(); cls != null; cls = cls.getSuperclass()) {
            for (Field fld : cls.getDeclaredFields()) {
                if (fields.contains(fld) || ignoreStatics && Modifier.isStatic(fld.getModifiers())) continue;
                fields.add(fld);
            }
            if (parentFields) continue;
        }
        for (Field field : fields) {
            String val;
            field.setAccessible(true);
            try {
                Object fldObj = field.get(o);
                val = fldObj == null ? "NULL" : fldObj.toString();
            }
            catch (Throwable e) {
                e.printStackTrace();
                val = "<ERROR>";
            }
            String type = simpleTypes ? field.getType().getSimpleName() : field.getType().toString();
            result = result + String.format("\t%s [%s] = %s;\n", field.getName(), type, val);
        }
        result = result + "]\n";
        return result;
    }

    public static HtmTemplates parseTemplates(String filename, Language lang, String html) {
        if (html == null) {
            return null;
        }
        Matcher m = _pattern.matcher(html);
        HtmTemplates tpls = new HtmTemplates(filename, lang);
        while (m.find()) {
            tpls.put(Integer.parseInt(m.group(2)), m.group(3));
            html = html.replace(m.group(0), "");
        }
        tpls.put(0, html);
        return tpls;
    }

    public static boolean isDigit(String text) {
        return text != null && text.matches("[0-9]+");
    }

    public static boolean arrayContains(@Nullable Object[] array, @Nullable Object objectToLookFor) {
        if (array == null || objectToLookFor == null) {
            return false;
        }
        for (Object objectInArray : array) {
            if (objectInArray == null || !objectInArray.equals(objectToLookFor)) continue;
            return true;
        }
        return false;
    }

    static {
        adenaFormatter = NumberFormat.getIntegerInstance(Locale.FRANCE);
        df = (DecimalFormat)NumberFormat.getNumberInstance(Locale.ENGLISH);
        df.applyPattern(PATTERN);
        df.setPositivePrefix("+");
        _pattern = Pattern.compile("<!--(TEMPLATE|TEMPLET)(\\d+)(.*?)(TEMPLATE|TEMPLET)-->", 32);
    }
}

