/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.taskmanager.tasks;

import l2s.gameserver.ThreadPoolManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AutomaticTask
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(AutomaticTask.class);

    public AutomaticTask() {
        this.init(true);
    }

    public abstract void doTask() throws Exception;

    public abstract long reCalcTime(boolean var1);

    public void init(boolean start) {
        ThreadPoolManager.getInstance().schedule(this, this.reCalcTime(start) - System.currentTimeMillis());
    }

    @Override
    public void run() {
        try {
            this.doTask();
        }
        catch (Exception e) {
            _log.error("Exception: " + e, (Throwable)e);
        }
        finally {
            this.init(false);
        }
    }
}

