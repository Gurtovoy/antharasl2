/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.mutable.MutableLong
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.commons.threading;

import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Delayed;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.RunnableScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicBoolean;
import l2s.commons.collections.LazyArrayList;
import org.apache.commons.lang3.mutable.MutableLong;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class SteppingRunnableQueueManager
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(SteppingRunnableQueueManager.class);
    protected final long tickPerStepInMillis;
    private final List<SteppingScheduledFuture<?>> queue = new CopyOnWriteArrayList();
    private final AtomicBoolean isRunning = new AtomicBoolean();

    public SteppingRunnableQueueManager(long tickPerStepInMillis) {
        this.tickPerStepInMillis = tickPerStepInMillis;
    }

    public SteppingScheduledFuture<?> schedule(Runnable r, long delay) {
        return this.schedule(r, delay, delay, false);
    }

    public SteppingScheduledFuture<?> scheduleAtFixedRate(Runnable r, long initial, long delay) {
        return this.schedule(r, initial, delay, true);
    }

    private SteppingScheduledFuture<?> schedule(Runnable r, long initial, long delay, boolean isPeriodic) {
        long initialStepping = this.getStepping(initial);
        long stepping = this.getStepping(delay);
        SteppingScheduledFuture sr = new SteppingScheduledFuture(r, initialStepping, stepping, isPeriodic);
        this.queue.add(sr);
        return sr;
    }

    private long getStepping(long delay) {
        return (delay = Math.max(0L, delay)) % this.tickPerStepInMillis > this.tickPerStepInMillis / 2L ? delay / this.tickPerStepInMillis + 1L : (delay < this.tickPerStepInMillis ? 1L : delay / this.tickPerStepInMillis);
    }

    @Override
    public void run() {
        if (!this.isRunning.compareAndSet(false, true)) {
            _log.warn("Slow running queue, managed by " + this + ", queue size : " + this.queue.size() + "!");
            return;
        }
        try {
            if (this.queue.isEmpty()) {
                return;
            }
            for (SteppingScheduledFuture<?> sr : this.queue) {
                if (sr.isDone()) continue;
                sr.run();
            }
        }
        finally {
            this.isRunning.set(false);
        }
    }

    public void purge() {
        LazyArrayList<SteppingScheduledFuture<?>> purge = LazyArrayList.newInstance();
        for (SteppingScheduledFuture<?> sr : this.queue) {
            if (!sr.isDone()) continue;
            purge.add(sr);
        }
        this.queue.removeAll(purge);
        LazyArrayList.recycle(purge);
    }

    public CharSequence getStats() {
        StringBuilder list = new StringBuilder();
        TreeMap<String, MutableLong> stats = new TreeMap<String, MutableLong>();
        int total = 0;
        int done = 0;
        for (SteppingScheduledFuture<?> steppingScheduledFuture : this.queue) {
            if (steppingScheduledFuture.isDone()) {
                ++done;
                continue;
            }
            ++total;
            MutableLong count = (MutableLong)stats.get(((SteppingScheduledFuture)steppingScheduledFuture).r.getClass().getName());
            if (count == null) {
                count = new MutableLong(1L);
                stats.put(((SteppingScheduledFuture)steppingScheduledFuture).r.getClass().getName(), count);
                continue;
            }
            count.increment();
        }
        for (Map.Entry entry : stats.entrySet()) {
            list.append("\t").append((String)entry.getKey()).append(" : ").append(((MutableLong)entry.getValue()).longValue()).append("\n");
        }
        list.append("Scheduled: ....... ").append(total).append("\n");
        list.append("Done/Cancelled: .. ").append(done).append("\n");
        return list;
    }

    public class SteppingScheduledFuture<V>
    implements RunnableScheduledFuture<V> {
        private final Runnable r;
        private final long stepping;
        private final boolean isPeriodic;
        private long step;
        private boolean isCancelled;

        public SteppingScheduledFuture(Runnable r, long initial, long stepping, boolean isPeriodic) {
            this.r = r;
            this.step = initial;
            this.stepping = stepping;
            this.isPeriodic = isPeriodic;
        }

        @Override
        public void run() {
            if (--this.step == 0L) {
                try {
                    this.r.run();
                }
                catch (Exception e) {
                    _log.error("SteppingScheduledFuture.run():" + e, (Throwable)e);
                }
                finally {
                    if (this.isPeriodic) {
                        this.step = this.stepping;
                    }
                }
            }
        }

        @Override
        public boolean isDone() {
            return this.isCancelled || !this.isPeriodic && this.step == 0L;
        }

        @Override
        public boolean isCancelled() {
            return this.isCancelled;
        }

        @Override
        public boolean cancel(boolean mayInterruptIfRunning) {
            this.isCancelled = true;
            return true;
        }

        @Override
        public V get() throws InterruptedException, ExecutionException {
            return null;
        }

        @Override
        public V get(long timeout, TimeUnit unit) throws InterruptedException, ExecutionException, TimeoutException {
            return null;
        }

        @Override
        public long getDelay(TimeUnit unit) {
            return unit.convert(this.step * SteppingRunnableQueueManager.this.tickPerStepInMillis, TimeUnit.MILLISECONDS);
        }

        @Override
        public int compareTo(Delayed o) {
            return 0;
        }

        @Override
        public boolean isPeriodic() {
            return this.isPeriodic;
        }
    }
}

