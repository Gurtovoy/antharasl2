/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.util.concurrent.atomic;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

public class AtomicLoopInteger {
    private static final AtomicIntegerFieldUpdater<AtomicLoopInteger> stateUpdater = AtomicIntegerFieldUpdater.newUpdater(AtomicLoopInteger.class, "value");
    private volatile int value;
    private final int min;
    private final int max;

    public AtomicLoopInteger(int initialValue, int min, int max) {
        this.min = min;
        this.max = max;
        this.value = initialValue;
    }

    public int get() {
        return this.value;
    }

    public final int incrementAndGet() {
        while (true) {
            int result;
            if ((result = stateUpdater.get(this)) < this.max) {
                if (!stateUpdater.compareAndSet(this, result, result + 1)) continue;
                return result + 1;
            }
            if (stateUpdater.compareAndSet(this, this.max, this.min)) break;
        }
        return this.min;
    }

    public final int getAndIncrement() {
        while (true) {
            int result;
            if ((result = stateUpdater.get(this)) < this.max) {
                if (!stateUpdater.compareAndSet(this, result, result + 1)) continue;
                return result;
            }
            if (stateUpdater.compareAndSet(this, this.max, this.min)) break;
        }
        return this.max;
    }

    public final int decrementAndGet() {
        while (true) {
            int result;
            if ((result = stateUpdater.get(this)) > this.min) {
                if (!stateUpdater.compareAndSet(this, result, result - 1)) continue;
                return result - 1;
            }
            if (stateUpdater.compareAndSet(this, this.min, this.max)) break;
        }
        return this.max;
    }

    public final int getAndDecrement() {
        while (true) {
            int result;
            if ((result = stateUpdater.get(this)) > this.min) {
                if (!stateUpdater.compareAndSet(this, result, result - 1)) continue;
                return result;
            }
            if (stateUpdater.compareAndSet(this, this.min, this.max)) break;
        }
        return this.min;
    }
}

