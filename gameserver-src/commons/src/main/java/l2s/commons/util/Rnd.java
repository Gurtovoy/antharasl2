/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.math3.random.MersenneTwister
 *  org.apache.commons.math3.random.RandomGenerator
 */
package l2s.commons.util;

import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import org.apache.commons.math3.random.MersenneTwister;
import org.apache.commons.math3.random.RandomGenerator;

public class Rnd {
    private static final ThreadLocal<RandomGenerator> rnd = new ThreadLocalGeneratorHolder();
    private static AtomicLong seedUniquifier = new AtomicLong(8682522807148012L);

    private Rnd() {
    }

    private static RandomGenerator rnd() {
        return rnd.get();
    }

    public static double get() {
        return Rnd.rnd().nextDouble();
    }

    public static int get(int n) {
        return Rnd.rnd().nextInt(n);
    }

    public static long get(long n) {
        return (long)(Rnd.rnd().nextDouble() * (double)n);
    }

    public static int get(int min, int max) {
        return min + Rnd.get(max - min + 1);
    }

    public static long get(long min, long max) {
        return min + Rnd.get(max - min + 1L);
    }

    public static int nextInt() {
        return Rnd.rnd().nextInt();
    }

    public static double nextDouble() {
        return Rnd.rnd().nextDouble();
    }

    public static double nextGaussian() {
        return Rnd.rnd().nextGaussian();
    }

    public static boolean nextBoolean() {
        return Rnd.rnd().nextBoolean();
    }

    public static boolean chance(int chance) {
        return chance >= 1 && (chance > 99 || Rnd.rnd().nextInt(99) + 1 <= chance);
    }

    public static boolean chance(double chance) {
        return Rnd.rnd().nextDouble() <= chance / 100.0;
    }

    public static <E> E get(E[] list) {
        if (list.length == 0) {
            return null;
        }
        if (list.length == 1) {
            return list[0];
        }
        return list[Rnd.get(list.length)];
    }

    public static int get(int[] list) {
        return list[Rnd.get(list.length)];
    }

    public static <E> E get(List<E> list) {
        if (list.isEmpty()) {
            return null;
        }
        if (list.size() == 1) {
            return list.get(0);
        }
        return list.get(Rnd.get(list.size()));
    }

    static final class ThreadLocalGeneratorHolder
    extends ThreadLocal<RandomGenerator> {
        ThreadLocalGeneratorHolder() {
        }

        @Override
        public RandomGenerator initialValue() {
            return new MersenneTwister(seedUniquifier.getAndIncrement() + System.nanoTime());
        }
    }
}

