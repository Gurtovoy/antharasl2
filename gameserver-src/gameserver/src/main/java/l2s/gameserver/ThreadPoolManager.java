package l2s.gameserver;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.RejectedExecutionHandler;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import l2s.commons.threading.PriorityThreadFactory;
import l2s.commons.threading.RejectedExecutionHandlerImpl;
import l2s.commons.threading.RunnableWrapper;
import l2s.gameserver.Config;
import l2s.gameserver.database.DatabaseFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ThreadPoolManager {
    private static final Logger _log = LoggerFactory.getLogger(ThreadPoolManager.class);
    private static final long MAX_DELAY = TimeUnit.NANOSECONDS.toMillis(Long.MAX_VALUE - System.nanoTime()) / 2L;
    private static final ThreadPoolManager _instance = new ThreadPoolManager();
    private final ScheduledThreadPoolExecutor _scheduledExecutor = new ScheduledThreadPoolExecutor(Config.SCHEDULED_THREAD_POOL_SIZE, (ThreadFactory)new PriorityThreadFactory("ScheduledThreadPool", 5), new ThreadPoolExecutor.CallerRunsPolicy());
    private final ThreadPoolExecutor _executor;
    private boolean _shutdown;

    public static ThreadPoolManager getInstance() {
        return _instance;
    }

    private ThreadPoolManager() {
        this._scheduledExecutor.setRejectedExecutionHandler((RejectedExecutionHandler)new RejectedExecutionHandlerImpl());
        this._scheduledExecutor.prestartAllCoreThreads();
        int coreThreads = Config.EXECUTOR_THREAD_POOL_SIZE;
        int maxThreads = Math.max(coreThreads, Config.EXECUTOR_THREAD_POOL_MAXIMUM);
        this._executor = new ThreadPoolExecutor(coreThreads, maxThreads, 5L, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>(100000), (ThreadFactory)new PriorityThreadFactory("ThreadPoolExecutor", 5), new RejectedExecutionHandler() {
            @Override
            public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
                if (executor.isShutdown()) {
                    return;
                }
                _log.error("ThreadPool queue full ({} queued); task dropped: {}", executor.getQueue().size(), r);
            }
        });
        this._executor.prestartAllCoreThreads();
        this.scheduleAtFixedRate(() -> {
            this._scheduledExecutor.purge();
            this._executor.purge();
            if (_log.isDebugEnabled()) {
                try {
                    int busy = DatabaseFactory.getInstance().getBusyConnectionCount();
                    int idle = DatabaseFactory.getInstance().getIdleConnectionCount();
                    _log.debug("DB pool: active={}, idle={}", busy, idle);
                }
                catch (Exception ignored) {
                }
            }
        }, 5L, 5L, TimeUnit.MINUTES);
    }

    private long validate(long delay, TimeUnit timeUnit) {
        long validatedDelay;
        long delayInMilliseconds = timeUnit.toMillis(delay);
        if (delayInMilliseconds > (validatedDelay = Math.max(0L, Math.min(MAX_DELAY, delayInMilliseconds)))) {
            return -1L;
        }
        return timeUnit.convert(delayInMilliseconds, TimeUnit.MILLISECONDS);
    }

    public boolean isShutdown() {
        return this._shutdown;
    }

    public ScheduledFuture<?> schedule(Runnable r, long delay, TimeUnit timeUnit) {
        if ((delay = this.validate(delay, timeUnit)) == -1L) {
            return null;
        }
        return this._scheduledExecutor.schedule((Runnable)new RunnableWrapper(r), delay, timeUnit);
    }

    public ScheduledFuture<?> schedule(Runnable r, long delay) {
        return this.schedule(r, delay, TimeUnit.MILLISECONDS);
    }

    public ScheduledFuture<?> scheduleAtFixedRate(Runnable r, long initial, long delay, TimeUnit timeUnit) {
        if ((initial = this.validate(initial, timeUnit)) == -1L) {
            return null;
        }
        if ((delay = this.validate(delay, timeUnit)) == -1L) {
            return this._scheduledExecutor.schedule((Runnable)new RunnableWrapper(r), initial, timeUnit);
        }
        return this._scheduledExecutor.scheduleAtFixedRate((Runnable)new RunnableWrapper(r), initial, delay, timeUnit);
    }

    public ScheduledFuture<?> scheduleAtFixedRate(Runnable r, long initial, long delay) {
        return this.scheduleAtFixedRate(r, initial, delay, TimeUnit.MILLISECONDS);
    }

    public ScheduledFuture<?> scheduleAtFixedDelay(Runnable r, long initial, long delay, TimeUnit timeUnit) {
        if ((initial = this.validate(initial, timeUnit)) == -1L) {
            return null;
        }
        if ((delay = this.validate(delay, timeUnit)) == -1L) {
            return this._scheduledExecutor.schedule((Runnable)new RunnableWrapper(r), initial, timeUnit);
        }
        return this._scheduledExecutor.scheduleWithFixedDelay((Runnable)new RunnableWrapper(r), initial, delay, timeUnit);
    }

    public ScheduledFuture<?> scheduleAtFixedDelay(Runnable r, long initial, long delay) {
        return this.scheduleAtFixedDelay(r, initial, delay, TimeUnit.MILLISECONDS);
    }

    public void execute(Runnable r) {
        this._executor.execute((Runnable)new RunnableWrapper(r));
    }

    public void shutdown() throws InterruptedException {
        this._shutdown = true;
        try {
            this._scheduledExecutor.shutdown();
            this._scheduledExecutor.awaitTermination(10L, TimeUnit.SECONDS);
        }
        finally {
            this._executor.shutdown();
            this._executor.awaitTermination(1L, TimeUnit.MINUTES);
        }
    }

    public CharSequence getStats() {
        StringBuilder list = new StringBuilder();
        list.append("ScheduledThreadPool\n");
        list.append("=================================================\n");
        list.append("\tgetActiveCount: ...... ").append(this._scheduledExecutor.getActiveCount()).append("\n");
        list.append("\tgetCorePoolSize: ..... ").append(this._scheduledExecutor.getCorePoolSize()).append("\n");
        list.append("\tgetPoolSize: ......... ").append(this._scheduledExecutor.getPoolSize()).append("\n");
        list.append("\tgetLargestPoolSize: .. ").append(this._scheduledExecutor.getLargestPoolSize()).append("\n");
        list.append("\tgetMaximumPoolSize: .. ").append(this._scheduledExecutor.getMaximumPoolSize()).append("\n");
        list.append("\tgetCompletedTaskCount: ").append(this._scheduledExecutor.getCompletedTaskCount()).append("\n");
        list.append("\tgetQueuedTaskCount: .. ").append(this._scheduledExecutor.getQueue().size()).append("\n");
        list.append("\tgetTaskCount: ........ ").append(this._scheduledExecutor.getTaskCount()).append("\n");
        list.append("ThreadPoolExecutor\n");
        list.append("=================================================\n");
        list.append("\tgetActiveCount: ...... ").append(this._executor.getActiveCount()).append("\n");
        list.append("\tgetCorePoolSize: ..... ").append(this._executor.getCorePoolSize()).append("\n");
        list.append("\tgetPoolSize: ......... ").append(this._executor.getPoolSize()).append("\n");
        list.append("\tgetLargestPoolSize: .. ").append(this._executor.getLargestPoolSize()).append("\n");
        list.append("\tgetMaximumPoolSize: .. ").append(this._executor.getMaximumPoolSize()).append("\n");
        list.append("\tgetCompletedTaskCount: ").append(this._executor.getCompletedTaskCount()).append("\n");
        list.append("\tgetQueuedTaskCount: .. ").append(this._executor.getQueue().size()).append("\n");
        list.append("\tgetTaskCount: ........ ").append(this._executor.getTaskCount()).append("\n");
        return list;
    }
}

