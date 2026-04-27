/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class StartStopAction
implements EventAction {
    public static final String EVENT = "event";
    private final String _name;
    private final boolean _start;

    public StartStopAction(String name, boolean start) {
        this._name = name;
        this._start = start;
    }

    @Override
    public void call(Event event) {
        event.action(this._name, this._start);
    }

    public String getName() {
        return this._name;
    }

    public boolean isStart() {
        return this._start;
    }
}

