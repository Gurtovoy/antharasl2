package l2s.authserver;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.RejectedExecutionHandler;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import l2s.commons.threading.RejectedExecutionHandlerImpl;
import l2s.commons.threading.RunnableWrapper;

public class ThreadPoolManager {
    private static final long MAX_DELAY = TimeUnit.NANOSECONDS.toMillis(Long.MAX_VALUE - System.nanoTime()) / 2L;
    private static final ThreadPoolManager _instance = new ThreadPoolManager();
    private final ScheduledThreadPoolExecutor _scheduledExecutor = new ScheduledThreadPoolExecutor(1);
    private final ThreadPoolExecutor _executor;

    public static final ThreadPoolManager getInstance() {
        return _instance;
    }

    private ThreadPoolManager() {
        this._scheduledExecutor.setRejectedExecutionHandler((RejectedExecutionHandler)new RejectedExecutionHandlerImpl());
        this._scheduledExecutor.prestartAllCoreThreads();
        this._executor = new ThreadPoolExecutor(1, 1, 5L, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
        this._executor.setRejectedExecutionHandler((RejectedExecutionHandler)new RejectedExecutionHandlerImpl());
        this._executor.prestartAllCoreThreads();
        this.scheduleAtFixedRate(() -> {
            this._scheduledExecutor.purge();
            this._executor.purge();
        }, 600000L, 600000L);
    }

    private final long validate(long delay) {
        return Math.max(0L, Math.min(MAX_DELAY, delay));
    }

    public void execute(Runnable r) {
        this._executor.execute((Runnable)new RunnableWrapper(r));
    }

    public ScheduledFuture<?> schedule(Runnable r, long delay) {
        return this._scheduledExecutor.schedule((Runnable)new RunnableWrapper(r), this.validate(delay), TimeUnit.MILLISECONDS);
    }

    public ScheduledFuture<?> scheduleAtFixedRate(Runnable r, long initial, long delay) {
        return this._scheduledExecutor.scheduleAtFixedRate((Runnable)new RunnableWrapper(r), this.validate(initial), this.validate(delay), TimeUnit.MILLISECONDS);
    }
}

