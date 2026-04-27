/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.time.cron;

import java.util.ArrayList;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.TimeZone;
import java.util.TreeMap;
import l2s.commons.time.cron.NextTime;
import l2s.commons.util.Rnd;

public class SchedulingPattern
implements NextTime {
    private static final int MINUTE_MIN_VALUE = 0;
    private static final int MINUTE_MAX_VALUE = 59;
    private static final int HOUR_MIN_VALUE = 0;
    private static final int HOUR_MAX_VALUE = 23;
    private static final int DAY_OF_MONTH_MIN_VALUE = 1;
    private static final int DAY_OF_MONTH_MAX_VALUE = 31;
    private static final int MONTH_MIN_VALUE = 1;
    private static final int MONTH_MAX_VALUE = 12;
    private static final int DAY_OF_WEEK_MIN_VALUE = 0;
    private static final int DAY_OF_WEEK_MAX_VALUE = 7;
    private static final ValueParser MINUTE_VALUE_PARSER = new MinuteValueParser();
    private static final ValueParser HOUR_VALUE_PARSER = new HourValueParser();
    private static final ValueParser DAY_OF_MONTH_VALUE_PARSER = new DayOfMonthValueParser();
    private static final ValueParser MONTH_VALUE_PARSER = new MonthValueParser();
    private static final ValueParser DAY_OF_WEEK_VALUE_PARSER = new DayOfWeekValueParser();
    private String asString;
    protected List<ValueMatcher> minuteMatchers = new ArrayList<ValueMatcher>();
    protected List<ValueMatcher> hourMatchers = new ArrayList<ValueMatcher>();
    protected List<ValueMatcher> dayOfMonthMatchers = new ArrayList<ValueMatcher>();
    protected List<ValueMatcher> monthMatchers = new ArrayList<ValueMatcher>();
    protected List<ValueMatcher> dayOfWeekMatchers = new ArrayList<ValueMatcher>();
    protected int matcherSize = 0;
    protected Map<Integer, Integer> hourAdder = new TreeMap<Integer, Integer>();
    protected Map<Integer, Integer> hourAdderRnd = new TreeMap<Integer, Integer>();
    protected Map<Integer, Integer> dayOfYearAdder = new TreeMap<Integer, Integer>();
    protected Map<Integer, Integer> minuteAdder = new TreeMap<Integer, Integer>();
    protected Map<Integer, Integer> minuteAdderRnd = new TreeMap<Integer, Integer>();
    protected Map<Integer, Integer> weekOfYearAdder = new TreeMap<Integer, Integer>();

    public static boolean validate(String schedulingPattern) {
        try {
            new SchedulingPattern(schedulingPattern);
        }
        catch (InvalidPatternException e) {
            return false;
        }
        return true;
    }

    public SchedulingPattern(String pattern) throws InvalidPatternException {
        this.asString = pattern;
        StringTokenizer st1 = new StringTokenizer(pattern, "|");
        if (st1.countTokens() < 1) {
            throw new InvalidPatternException("invalid pattern: \"" + pattern + "\"");
        }
        while (st1.hasMoreTokens()) {
            int i;
            String localPattern = st1.nextToken();
            StringTokenizer st2 = new StringTokenizer(localPattern, " \t");
            int tokCnt = st2.countTokens();
            if (tokCnt < 5 || tokCnt > 6) {
                throw new InvalidPatternException("invalid pattern: \"" + localPattern + "\"");
            }
            try {
                String minutePattern = st2.nextToken();
                String[] minutePatternParts = minutePattern.split(":");
                if (minutePatternParts.length > 1) {
                    for (i = 0; i < minutePatternParts.length - 1; ++i) {
                        if (minutePatternParts[i].length() <= 1) continue;
                        if (minutePatternParts[i].startsWith("+")) {
                            this.minuteAdder.put(this.matcherSize, Integer.parseInt(minutePatternParts[i].substring(1)));
                            continue;
                        }
                        if (minutePatternParts[i].startsWith("~")) {
                            this.minuteAdderRnd.put(this.matcherSize, Integer.parseInt(minutePatternParts[i].substring(1)));
                            continue;
                        }
                        throw new InvalidPatternException("Unknown hour modifier \"" + minutePatternParts[i] + "\"");
                    }
                    minutePattern = minutePatternParts[minutePatternParts.length - 1];
                }
                this.minuteMatchers.add(this.buildValueMatcher(minutePattern, MINUTE_VALUE_PARSER));
            }
            catch (Exception e) {
                throw new InvalidPatternException("invalid pattern \"" + localPattern + "\". Error parsing minutes field: " + e.getMessage() + ".");
            }
            try {
                String hourPattern = st2.nextToken();
                String[] hourPatternParts = hourPattern.split(":");
                if (hourPatternParts.length > 1) {
                    for (i = 0; i < hourPatternParts.length - 1; ++i) {
                        if (hourPatternParts[i].length() <= 1) continue;
                        if (hourPatternParts[i].startsWith("+")) {
                            this.hourAdder.put(this.matcherSize, Integer.parseInt(hourPatternParts[i].substring(1)));
                            continue;
                        }
                        if (hourPatternParts[i].startsWith("~")) {
                            this.hourAdderRnd.put(this.matcherSize, Integer.parseInt(hourPatternParts[i].substring(1)));
                            continue;
                        }
                        throw new InvalidPatternException("Unknown hour modifier \"" + hourPatternParts[i] + "\"");
                    }
                    hourPattern = hourPatternParts[hourPatternParts.length - 1];
                }
                this.hourMatchers.add(this.buildValueMatcher(hourPattern, HOUR_VALUE_PARSER));
            }
            catch (Exception e) {
                throw new InvalidPatternException("invalid pattern \"" + localPattern + "\". Error parsing hours field: " + e.getMessage() + ".");
            }
            try {
                String dayOfMonthPattern = st2.nextToken();
                String[] dayOfMonthPatternParts = dayOfMonthPattern.split(":");
                if (dayOfMonthPatternParts.length > 1) {
                    for (i = 0; i < dayOfMonthPatternParts.length - 1; ++i) {
                        if (dayOfMonthPatternParts[i].length() <= 1) continue;
                        if (dayOfMonthPatternParts[i].startsWith("+")) {
                            this.dayOfYearAdder.put(this.matcherSize, Integer.parseInt(dayOfMonthPatternParts[i].substring(1)));
                            continue;
                        }
                        throw new InvalidPatternException("Unknown day modifier \"" + dayOfMonthPatternParts[i] + "\"");
                    }
                    dayOfMonthPattern = dayOfMonthPatternParts[dayOfMonthPatternParts.length - 1];
                }
                this.dayOfMonthMatchers.add(this.buildValueMatcher(dayOfMonthPattern, DAY_OF_MONTH_VALUE_PARSER));
            }
            catch (Exception e) {
                throw new InvalidPatternException("invalid pattern \"" + localPattern + "\". Error parsing days of month field: " + e.getMessage() + ".");
            }
            try {
                this.monthMatchers.add(this.buildValueMatcher(st2.nextToken(), MONTH_VALUE_PARSER));
            }
            catch (Exception e) {
                throw new InvalidPatternException("invalid pattern \"" + localPattern + "\". Error parsing months field: " + e.getMessage() + ".");
            }
            try {
                this.dayOfWeekMatchers.add(this.buildValueMatcher(st2.nextToken(), DAY_OF_WEEK_VALUE_PARSER));
            }
            catch (Exception e) {
                throw new InvalidPatternException("invalid pattern \"" + localPattern + "\". Error parsing days of week field: " + e.getMessage() + ".");
            }
            if (st2.hasMoreTokens()) {
                try {
                    String weekOfYearAdderText = st2.nextToken();
                    if (weekOfYearAdderText.charAt(0) != '+') {
                        throw new InvalidPatternException("Unknown week of year addition in pattern \"" + localPattern + "\".");
                    }
                    weekOfYearAdderText = weekOfYearAdderText.substring(1);
                    this.weekOfYearAdder.put(this.matcherSize, Integer.parseInt(weekOfYearAdderText));
                }
                catch (Exception e) {
                    throw new InvalidPatternException("invalid pattern \"" + localPattern + "\". Error parsing days of week field: " + e.getMessage() + ".");
                }
            }
            ++this.matcherSize;
        }
    }

    private ValueMatcher buildValueMatcher(String str, ValueParser parser) throws Exception {
        if (str.length() == 1 && str.equals("*")) {
            return new AlwaysTrueValueMatcher();
        }
        ArrayList<Integer> values = new ArrayList<Integer>();
        StringTokenizer st = new StringTokenizer(str, ",");
        while (st.hasMoreTokens()) {
            List<Integer> local;
            String element = st.nextToken();
            try {
                local = this.parseListElement(element, parser);
            }
            catch (Exception e) {
                throw new Exception("invalid field \"" + str + "\", invalid element \"" + element + "\", " + e.getMessage());
            }
            for (Integer value : local) {
                if (values.contains(value)) continue;
                values.add(value);
            }
        }
        if (values.size() == 0) {
            throw new Exception("invalid field \"" + str + "\"");
        }
        if (parser == DAY_OF_MONTH_VALUE_PARSER) {
            return new DayOfMonthValueMatcher(values);
        }
        return new IntArrayValueMatcher(values);
    }

    private List<Integer> parseListElement(String str, ValueParser parser) throws Exception {
        List<Integer> values;
        StringTokenizer st = new StringTokenizer(str, "/");
        int size = st.countTokens();
        if (size < 1 || size > 2) {
            throw new Exception("syntax error");
        }
        try {
            values = this.parseRange(st.nextToken(), parser);
        }
        catch (Exception e) {
            throw new Exception("invalid range, " + e.getMessage());
        }
        if (size == 2) {
            int div;
            String dStr = st.nextToken();
            try {
                div = Integer.parseInt(dStr);
            }
            catch (NumberFormatException e) {
                throw new Exception("invalid divisor \"" + dStr + "\"");
            }
            if (div < 1) {
                throw new Exception("non positive divisor \"" + div + "\"");
            }
            ArrayList<Integer> values2 = new ArrayList<Integer>();
            for (int i = 0; i < values.size(); i += div) {
                values2.add(values.get(i));
            }
            return values2;
        }
        return values;
    }

    private List<Integer> parseRange(String str, ValueParser parser) throws Exception {
        int v2;
        int v1;
        if (str.equals("*")) {
            int min = parser.getMinValue();
            int max = parser.getMaxValue();
            ArrayList<Integer> values = new ArrayList<Integer>();
            for (int i = min; i <= max; ++i) {
                values.add(new Integer(i));
            }
            return values;
        }
        StringTokenizer st = new StringTokenizer(str, "-");
        int size = st.countTokens();
        if (size < 1 || size > 2) {
            throw new Exception("syntax error");
        }
        String v1Str = st.nextToken();
        try {
            v1 = parser.parse(v1Str);
        }
        catch (Exception e) {
            throw new Exception("invalid value \"" + v1Str + "\", " + e.getMessage());
        }
        if (size == 1) {
            ArrayList<Integer> values = new ArrayList<Integer>();
            values.add(new Integer(v1));
            return values;
        }
        String v2Str = st.nextToken();
        try {
            v2 = parser.parse(v2Str);
        }
        catch (Exception e) {
            throw new Exception("invalid value \"" + v2Str + "\", " + e.getMessage());
        }
        ArrayList<Integer> values = new ArrayList<Integer>();
        if (v1 < v2) {
            for (int i = v1; i <= v2; ++i) {
                values.add(new Integer(i));
            }
        } else if (v1 > v2) {
            int i;
            int min = parser.getMinValue();
            int max = parser.getMaxValue();
            for (i = v1; i <= max; ++i) {
                values.add(new Integer(i));
            }
            for (i = min; i <= v2; ++i) {
                values.add(new Integer(i));
            }
        } else {
            values.add(new Integer(v1));
        }
        return values;
    }

    public boolean match(TimeZone timezone, long millis) {
        GregorianCalendar gc = new GregorianCalendar(timezone);
        gc.setTimeInMillis(millis);
        gc.set(13, 0);
        gc.set(14, 0);
        for (int i = 0; i < this.matcherSize; ++i) {
            boolean eval;
            if (this.weekOfYearAdder.containsKey(i)) {
                gc.add(3, -this.weekOfYearAdder.get(i).intValue());
            }
            if (this.dayOfYearAdder.containsKey(i)) {
                gc.add(6, -this.dayOfYearAdder.get(i).intValue());
            }
            if (this.hourAdder.containsKey(i)) {
                gc.add(10, -this.hourAdder.get(i).intValue());
            }
            if (this.minuteAdder.containsKey(i)) {
                gc.add(12, -this.minuteAdder.get(i).intValue());
            }
            int minute = gc.get(12);
            int hour = gc.get(11);
            int dayOfMonth = gc.get(5);
            int month = gc.get(2) + 1;
            int dayOfWeek = gc.get(7) - 1;
            int year = gc.get(1);
            ValueMatcher minuteMatcher = this.minuteMatchers.get(i);
            ValueMatcher hourMatcher = this.hourMatchers.get(i);
            ValueMatcher dayOfMonthMatcher = this.dayOfMonthMatchers.get(i);
            ValueMatcher monthMatcher = this.monthMatchers.get(i);
            ValueMatcher dayOfWeekMatcher = this.dayOfWeekMatchers.get(i);
            eval = minuteMatcher.match(minute) && hourMatcher.match(hour) && (dayOfMonthMatcher instanceof DayOfMonthValueMatcher ? ((DayOfMonthValueMatcher)dayOfMonthMatcher).match(dayOfMonth, month, gc.isLeapYear(year)) : dayOfMonthMatcher.match(dayOfMonth)) && monthMatcher.match(month) && dayOfWeekMatcher.match(dayOfWeek);
            if (!eval) continue;
            return true;
        }
        return false;
    }

    public boolean match(long millis) {
        return this.match(TimeZone.getDefault(), millis);
    }

    public long next(TimeZone timezone, long millis) {
        long result = -1L;
        GregorianCalendar gc = new GregorianCalendar(timezone);
        for (int i = 0; i < this.matcherSize; ++i) {
            long next = -1L;
            gc.setTimeInMillis(millis);
            gc.set(13, 0);
            gc.set(14, 0);
            if (this.weekOfYearAdder.containsKey(i)) {
                gc.add(3, this.weekOfYearAdder.get(i));
            }
            if (this.dayOfYearAdder.containsKey(i)) {
                gc.add(6, this.dayOfYearAdder.get(i));
            }
            if (this.hourAdder.containsKey(i)) {
                gc.add(10, this.hourAdder.get(i));
            }
            if (this.minuteAdder.containsKey(i)) {
                gc.add(12, this.minuteAdder.get(i));
            }
            ValueMatcher minuteMatcher = this.minuteMatchers.get(i);
            ValueMatcher hourMatcher = this.hourMatchers.get(i);
            ValueMatcher dayOfMonthMatcher = this.dayOfMonthMatchers.get(i);
            ValueMatcher monthMatcher = this.monthMatchers.get(i);
            ValueMatcher dayOfWeekMatcher = this.dayOfWeekMatchers.get(i);
            block1: while (true) {
                int year = gc.get(1);
                boolean isLeapYear = gc.isLeapYear(year);
                for (int month = gc.get(2) + 1; month <= 12; ++month) {
                    if (monthMatcher.match(month)) {
                        gc.set(2, month - 1);
                        int maxDayOfMonth = DayOfMonthValueMatcher.getLastDayOfMonth(month, isLeapYear);
                        for (int dayOfMonth = gc.get(5); dayOfMonth <= maxDayOfMonth; ++dayOfMonth) {
                            if (dayOfMonthMatcher instanceof DayOfMonthValueMatcher ? ((DayOfMonthValueMatcher)dayOfMonthMatcher).match(dayOfMonth, month, isLeapYear) : dayOfMonthMatcher.match(dayOfMonth)) {
                                gc.set(5, dayOfMonth);
                                int dayOfWeek = gc.get(7) - 1;
                                if (dayOfWeekMatcher.match(dayOfWeek)) {
                                    for (int hour = gc.get(11); hour <= 23; ++hour) {
                                        if (hourMatcher.match(hour)) {
                                            gc.set(11, hour);
                                            for (int minute = gc.get(12); minute <= 59; ++minute) {
                                                if (!minuteMatcher.match(minute)) continue;
                                                gc.set(12, minute);
                                                long next0 = gc.getTimeInMillis();
                                                if (next0 <= millis) continue;
                                                if (next != -1L && next0 >= next) break block1;
                                                next = next0;
                                                if (this.hourAdderRnd.containsKey(i)) {
                                                    next += (long)(Rnd.get(this.hourAdderRnd.get(i)) * 60 * 60) * 1000L;
                                                }
                                                if (!this.minuteAdderRnd.containsKey(i)) break block1;
                                                next += (long)(Rnd.get(this.minuteAdderRnd.get(i)) * 60) * 1000L;
                                                break block1;
                                            }
                                        }
                                        gc.set(12, 0);
                                    }
                                }
                            }
                            gc.set(11, 0);
                            gc.set(12, 0);
                        }
                    }
                    gc.set(5, 1);
                    gc.set(11, 0);
                    gc.set(12, 0);
                }
                gc.set(2, 0);
                gc.set(11, 0);
                gc.set(12, 0);
                gc.roll(1, true);
            }
            if (next <= millis || result != -1L && next >= result) continue;
            result = next;
        }
        return result;
    }

    @Override
    public long next(long millis) {
        return this.next(TimeZone.getDefault(), millis);
    }

    public String toString() {
        return this.asString;
    }

    private static int parseAlias(String value, String[] aliases, int offset) throws Exception {
        for (int i = 0; i < aliases.length; ++i) {
            if (!aliases[i].equalsIgnoreCase(value)) continue;
            return offset + i;
        }
        throw new Exception("invalid alias \"" + value + "\"");
    }

    private static class DayOfMonthValueMatcher
    extends IntArrayValueMatcher {
        private static final int[] lastDays = new int[]{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

        public DayOfMonthValueMatcher(List<Integer> integers) {
            super(integers);
        }

        public boolean match(int value, int month, boolean isLeapYear) {
            return super.match(value) || value > 27 && this.match(32) && DayOfMonthValueMatcher.isLastDayOfMonth(value, month, isLeapYear);
        }

        public static int getLastDayOfMonth(int month, boolean isLeapYear) {
            if (isLeapYear && month == 2) {
                return 29;
            }
            return lastDays[month - 1];
        }

        public static boolean isLastDayOfMonth(int value, int month, boolean isLeapYear) {
            return value == DayOfMonthValueMatcher.getLastDayOfMonth(month, isLeapYear);
        }
    }

    private static class IntArrayValueMatcher
    implements ValueMatcher {
        private int[] values;

        public IntArrayValueMatcher(List<Integer> integers) {
            int size = integers.size();
            this.values = new int[size];
            for (int i = 0; i < size; ++i) {
                try {
                    this.values[i] = integers.get(i);
                    continue;
                }
                catch (Exception e) {
                    throw new IllegalArgumentException(e.getMessage());
                }
            }
        }

        @Override
        public boolean match(int value) {
            for (int i = 0; i < this.values.length; ++i) {
                if (this.values[i] != value) continue;
                return true;
            }
            return false;
        }
    }

    private static class AlwaysTrueValueMatcher
    implements ValueMatcher {
        private AlwaysTrueValueMatcher() {
        }

        @Override
        public boolean match(int value) {
            return true;
        }
    }

    private static interface ValueMatcher {
        public boolean match(int var1);
    }

    private static class DayOfWeekValueParser
    extends SimpleValueParser {
        private static String[] ALIASES = new String[]{"sun", "mon", "tue", "wed", "thu", "fri", "sat"};

        public DayOfWeekValueParser() {
            super(0, 7);
        }

        @Override
        public int parse(String value) throws Exception {
            try {
                return super.parse(value) % 7;
            }
            catch (Exception e) {
                return SchedulingPattern.parseAlias(value, DayOfWeekValueParser.ALIASES, 0);
            }
        }
    }

    private static class MonthValueParser
    extends SimpleValueParser {
        private static String[] ALIASES = new String[]{"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"};

        public MonthValueParser() {
            super(1, 12);
        }

        @Override
        public int parse(String value) throws Exception {
            try {
                return super.parse(value);
            }
            catch (Exception e) {
                return SchedulingPattern.parseAlias(value, MonthValueParser.ALIASES, 1);
            }
        }
    }

    private static class DayOfMonthValueParser
    extends SimpleValueParser {
        public DayOfMonthValueParser() {
            super(1, 31);
        }

        @Override
        public int parse(String value) throws Exception {
            if (value.equalsIgnoreCase("L")) {
                return 32;
            }
            return super.parse(value);
        }
    }

    private static class HourValueParser
    extends SimpleValueParser {
        public HourValueParser() {
            super(0, 23);
        }
    }

    private static class MinuteValueParser
    extends SimpleValueParser {
        public MinuteValueParser() {
            super(0, 59);
        }
    }

    private static class SimpleValueParser
    implements ValueParser {
        protected int minValue;
        protected int maxValue;

        public SimpleValueParser(int minValue, int maxValue) {
            this.minValue = minValue;
            this.maxValue = maxValue;
        }

        @Override
        public int parse(String value) throws Exception {
            int i;
            try {
                i = Integer.parseInt(value);
            }
            catch (NumberFormatException e) {
                throw new Exception("invalid integer value");
            }
            if (i < this.minValue || i > this.maxValue) {
                throw new Exception("value out of range");
            }
            return i;
        }

        @Override
        public int getMinValue() {
            return this.minValue;
        }

        @Override
        public int getMaxValue() {
            return this.maxValue;
        }
    }

    private static interface ValueParser {
        public int parse(String var1) throws Exception;

        public int getMinValue();

        public int getMaxValue();
    }

    public class InvalidPatternException
    extends RuntimeException {
        private static final long serialVersionUID = 1L;

        InvalidPatternException() {
        }

        InvalidPatternException(String message) {
            super(message);
        }
    }
}

