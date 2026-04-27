/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.math;

public class SafeMath {
    public static int addAndCheck(int a, int b) throws ArithmeticException {
        return SafeMath.addAndCheck(a, b, "overflow: add", false);
    }

    public static int addAndLimit(int a, int b) {
        return SafeMath.addAndCheck(a, b, null, true);
    }

    /*
     * Enabled force condition propagation
     * Lifted jumps to return sites
     */
    private static int addAndCheck(int a, int b, String msg, boolean limit) {
        if (a > b) {
            return SafeMath.addAndCheck(b, a, msg, limit);
        }
        if (a < 0) {
            if (b >= 0) return a + b;
            if (Integer.MIN_VALUE - b <= a) {
                return a + b;
            }
            if (!limit) throw new ArithmeticException(msg);
            return Integer.MIN_VALUE;
        }
        if (a <= Integer.MAX_VALUE - b) {
            return a + b;
        }
        if (!limit) throw new ArithmeticException(msg);
        return Integer.MAX_VALUE;
    }

    public static long addAndLimit(long a, long b) {
        return SafeMath.addAndCheck(a, b, "overflow: add", true);
    }

    public static long addAndCheck(long a, long b) throws ArithmeticException {
        return SafeMath.addAndCheck(a, b, "overflow: add", false);
    }

    /*
     * Enabled force condition propagation
     * Lifted jumps to return sites
     */
    private static long addAndCheck(long a, long b, String msg, boolean limit) {
        if (a > b) {
            return SafeMath.addAndCheck(b, a, msg, limit);
        }
        if (a < 0L) {
            if (b >= 0L) return a + b;
            if (Long.MIN_VALUE - b <= a) {
                return a + b;
            }
            if (!limit) throw new ArithmeticException(msg);
            return Long.MIN_VALUE;
        }
        if (a <= Long.MAX_VALUE - b) {
            return a + b;
        }
        if (!limit) throw new ArithmeticException(msg);
        return Long.MAX_VALUE;
    }

    public static int mulAndCheck(int a, int b) throws ArithmeticException {
        return SafeMath.mulAndCheck(a, b, "overflow: mul", false);
    }

    public static int mulAndLimit(int a, int b) {
        return SafeMath.mulAndCheck(a, b, "overflow: mul", true);
    }

    /*
     * Enabled force condition propagation
     * Lifted jumps to return sites
     */
    private static int mulAndCheck(int a, int b, String msg, boolean limit) {
        if (a > b) {
            return SafeMath.mulAndCheck(b, a, msg, limit);
        }
        if (a < 0) {
            if (b < 0) {
                if (a >= Integer.MAX_VALUE / b) {
                    return a * b;
                }
                if (!limit) throw new ArithmeticException(msg);
                return Integer.MAX_VALUE;
            }
            if (b <= 0) return 0;
            if (Integer.MIN_VALUE / b <= a) {
                return a * b;
            }
            if (!limit) throw new ArithmeticException(msg);
            return Integer.MIN_VALUE;
        }
        if (a <= 0) return 0;
        if (a <= Integer.MAX_VALUE / b) {
            return a * b;
        }
        if (!limit) throw new ArithmeticException(msg);
        return Integer.MAX_VALUE;
    }

    public static long mulAndCheck(long a, long b) throws ArithmeticException {
        return SafeMath.mulAndCheck(a, b, "overflow: mul", false);
    }

    public static long mulAndLimit(long a, long b) {
        return SafeMath.mulAndCheck(a, b, "overflow: mul", true);
    }

    /*
     * Enabled force condition propagation
     * Lifted jumps to return sites
     */
    private static long mulAndCheck(long a, long b, String msg, boolean limit) {
        if (a > b) {
            return SafeMath.mulAndCheck(b, a, msg, limit);
        }
        if (a < 0L) {
            if (b < 0L) {
                if (a >= Long.MAX_VALUE / b) {
                    return a * b;
                }
                if (!limit) throw new ArithmeticException(msg);
                return Long.MAX_VALUE;
            }
            if (b <= 0L) return 0L;
            if (Long.MIN_VALUE / b <= a) {
                return a * b;
            }
            if (!limit) throw new ArithmeticException(msg);
            return Long.MIN_VALUE;
        }
        if (a <= 0L) return 0L;
        if (a <= Long.MAX_VALUE / b) {
            return a * b;
        }
        if (!limit) throw new ArithmeticException(msg);
        return Long.MAX_VALUE;
    }

    public static double mulAndCheck(double a, double b) throws ArithmeticException {
        return SafeMath.mulAndCheck(a, b, "overflow: mul", false);
    }

    public static double mulAndLimit(double a, double b) {
        return SafeMath.mulAndCheck(a, b, "overflow: mul", true);
    }

    /*
     * Enabled force condition propagation
     * Lifted jumps to return sites
     */
    private static double mulAndCheck(double a, double b, String msg, boolean limit) {
        if (a > b) {
            return SafeMath.mulAndCheck(b, a, msg, limit);
        }
        if (a < 0.0) {
            if (b < 0.0) {
                if (a >= Double.MAX_VALUE / b) {
                    return a * b;
                }
                if (!limit) throw new ArithmeticException(msg);
                return Double.MAX_VALUE;
            }
            if (!(b > 0.0)) return 0.0;
            if (Double.MIN_VALUE / b <= a) {
                return a * b;
            }
            if (!limit) throw new ArithmeticException(msg);
            return Double.MIN_VALUE;
        }
        if (!(a > 0.0)) return 0.0;
        if (a <= Double.MAX_VALUE / b) {
            return a * b;
        }
        if (!limit) throw new ArithmeticException(msg);
        return Double.MAX_VALUE;
    }
}

