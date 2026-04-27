/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.commons.threading;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class RunnableWrapper
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(RunnableWrapper.class);
    private final Runnable _runnable;

    public RunnableWrapper(Runnable runnable) {
        this._runnable = runnable;
    }

    @Override
    public void run() {
        try {
            this._runnable.run();
        }
        catch (Exception e) {
            _log.error("Exception: " + e, (Throwable)e);
        }
    }
}

