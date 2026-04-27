/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.util.concurrent.locks;

import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

public class ReentrantReadWriteLock {
    private static final AtomicIntegerFieldUpdater<ReentrantReadWriteLock> stateUpdater = AtomicIntegerFieldUpdater.newUpdater(ReentrantReadWriteLock.class, "state");
    static final int SHARED_SHIFT = 16;
    static final int SHARED_UNIT = 65536;
    static final int MAX_COUNT = 65535;
    static final int EXCLUSIVE_MASK = 65535;
    transient ThreadLocalHoldCounter readHolds = new ThreadLocalHoldCounter();
    transient HoldCounter cachedHoldCounter;
    private Thread owner;
    private volatile int state;

    static int sharedCount(int c) {
        return c >>> 16;
    }

    static int exclusiveCount(int c) {
        return c & 0xFFFF;
    }

    public ReentrantReadWriteLock() {
        this.setState(0);
    }

    private final int getState() {
        return this.state;
    }

    private void setState(int newState) {
        this.state = newState;
    }

    private boolean compareAndSetState(int expect, int update) {
        return stateUpdater.compareAndSet(this, expect, update);
    }

    private Thread getExclusiveOwnerThread() {
        return this.owner;
    }

    private void setExclusiveOwnerThread(Thread thread) {
        this.owner = thread;
    }

    public void writeLock() {
        Thread current = Thread.currentThread();
        while (true) {
            int c = this.getState();
            int w = ReentrantReadWriteLock.exclusiveCount(c);
            if (c != 0) {
                if (w == 0 || current != this.getExclusiveOwnerThread()) continue;
                if (w + ReentrantReadWriteLock.exclusiveCount(1) > 65535) {
                    throw new Error("Maximum lock count exceeded");
                }
            }
            if (this.compareAndSetState(c, c + 1)) break;
        }
        this.setExclusiveOwnerThread(current);
    }

    public boolean tryWriteLock() {
        Thread current = Thread.currentThread();
        int c = this.getState();
        if (c != 0) {
            int w = ReentrantReadWriteLock.exclusiveCount(c);
            if (w == 0 || current != this.getExclusiveOwnerThread()) {
                return false;
            }
            if (w == 65535) {
                throw new Error("Maximum lock count exceeded");
            }
        }
        if (!this.compareAndSetState(c, c + 1)) {
            return false;
        }
        this.setExclusiveOwnerThread(current);
        return true;
    }

    final boolean tryReadLock() {
        Thread current = Thread.currentThread();
        int c = this.getState();
        int w = ReentrantReadWriteLock.exclusiveCount(c);
        if (w != 0 && this.getExclusiveOwnerThread() != current) {
            return false;
        }
        if (ReentrantReadWriteLock.sharedCount(c) == 65535) {
            throw new Error("Maximum lock count exceeded");
        }
        if (this.compareAndSetState(c, c + 65536)) {
            HoldCounter rh = this.cachedHoldCounter;
            if (rh == null || rh.tid != current.getId()) {
                this.cachedHoldCounter = rh = (HoldCounter)this.readHolds.get();
            }
            ++rh.count;
            return true;
        }
        return false;
    }

    public void readLock() {
        Thread current = Thread.currentThread();
        HoldCounter rh = this.cachedHoldCounter;
        if (rh == null || rh.tid != current.getId()) {
            rh = (HoldCounter)this.readHolds.get();
        }
        while (true) {
            int c;
            int w;
            if ((w = ReentrantReadWriteLock.exclusiveCount(c = this.getState())) != 0 && this.getExclusiveOwnerThread() != current) {
                continue;
            }
            if (ReentrantReadWriteLock.sharedCount(c) == 65535) {
                throw new Error("Maximum lock count exceeded");
            }
            if (this.compareAndSetState(c, c + 65536)) break;
        }
        this.cachedHoldCounter = rh;
        ++rh.count;
    }

    public void writeUnlock() {
        int nextc = this.getState() - 1;
        if (Thread.currentThread() != this.getExclusiveOwnerThread()) {
            throw new IllegalMonitorStateException();
        }
        if (ReentrantReadWriteLock.exclusiveCount(nextc) == 0) {
            this.setExclusiveOwnerThread(null);
            this.setState(nextc);
            return;
        }
        this.setState(nextc);
    }

    public void readUnlock() {
        int nextc;
        int c;
        HoldCounter rh = this.cachedHoldCounter;
        Thread current = Thread.currentThread();
        if (rh == null || rh.tid != current.getId()) {
            rh = (HoldCounter)this.readHolds.get();
        }
        if (rh.tryDecrement() <= 0) {
            throw new IllegalMonitorStateException();
        }
        while (!this.compareAndSetState(c = this.getState(), nextc = c - 65536)) {
        }
    }

    static final class ThreadLocalHoldCounter
    extends ThreadLocal<HoldCounter> {
        ThreadLocalHoldCounter() {
        }

        @Override
        public HoldCounter initialValue() {
            return new HoldCounter();
        }
    }

    static final class HoldCounter {
        int count;
        final long tid = Thread.currentThread().getId();

        HoldCounter() {
        }

        int tryDecrement() {
            int c = this.count;
            if (c > 0) {
                this.count = c - 1;
            }
            return c;
        }
    }
}

