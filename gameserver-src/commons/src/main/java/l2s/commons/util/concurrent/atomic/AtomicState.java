package l2s.commons.util.concurrent.atomic;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

public class AtomicState {
    private static final AtomicIntegerFieldUpdater<AtomicState> stateUpdater = AtomicIntegerFieldUpdater.newUpdater(AtomicState.class, "value");
    private volatile int value;

    public AtomicState(boolean initialValue) {
        this.value = initialValue ? 1 : 0;
    }

    public AtomicState() {
    }

    public final boolean get() {
        return this.value != 0;
    }

    public final void set(boolean value) {
        this.value = value ? 1 : 0;
    }

    private boolean getBool(int value) {
        if (value < 0) {
            throw new IllegalStateException();
        }
        return value > 0;
    }

    public final boolean setAndGet(boolean newValue) {
        if (newValue) {
            return this.getBool(stateUpdater.incrementAndGet(this));
        }
        return this.getBool(stateUpdater.decrementAndGet(this));
    }

    public final boolean getAndSet(boolean newValue) {
        if (newValue) {
            return this.getBool(stateUpdater.getAndIncrement(this));
        }
        return this.getBool(stateUpdater.getAndDecrement(this));
    }
}

