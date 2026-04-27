/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.actor.flags.flag;

import java.util.concurrent.atomic.AtomicBoolean;
import l2s.gameserver.model.actor.flags.flag.DefaultFlag;

public class UndyingFlag
extends DefaultFlag {
    private final AtomicBoolean _flag = new AtomicBoolean(false);

    public AtomicBoolean getFlag() {
        return this._flag;
    }

    @Override
    public boolean start(Object owner) {
        this._flag.set(false);
        return super.start(owner);
    }

    @Override
    public boolean start() {
        this._flag.set(false);
        return super.start();
    }

    @Override
    public boolean stop(Object owner) {
        this._flag.set(false);
        return super.stop(owner);
    }

    @Override
    public boolean stop() {
        this._flag.set(false);
        return super.stop();
    }

    @Override
    public void clear() {
        this._flag.set(false);
        super.clear();
    }
}

