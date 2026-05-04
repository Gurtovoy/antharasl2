package l2s.commons.threading;

import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicInteger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PriorityThreadFactory
implements ThreadFactory {
    private static final Logger _log = LoggerFactory.getLogger(PriorityThreadFactory.class);
    private int _prio;
    private String _name;
    private AtomicInteger _threadNumber = new AtomicInteger(1);
    private ThreadGroup _group;

    public PriorityThreadFactory(String name, int prio) {
        this._prio = prio;
        this._name = name;
        this._group = new ThreadGroup(this._name);
    }

    @Override
    public Thread newThread(Runnable r) {
        Thread t = new Thread(this._group, r){

            @Override
            public void run() {
                try {
                    super.run();
                }
                catch (Exception e) {
                    _log.error("Exception: " + e, (Throwable)e);
                }
            }
        };
        t.setName(this._name + "-" + this._threadNumber.getAndIncrement());
        t.setPriority(this._prio);
        return t;
    }

    public ThreadGroup getGroup() {
        return this._group;
    }
}

