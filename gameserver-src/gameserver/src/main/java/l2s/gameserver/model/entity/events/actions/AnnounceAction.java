/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class AnnounceAction
implements EventAction {
    private final int _id;
    private final String _value;
    private final int _time;

    public AnnounceAction(int id, String value, int time) {
        this._id = id;
        this._value = value;
        this._time = time;
    }

    @Override
    public void call(Event event) {
        event.announce(this._id, this._value, this._time);
    }
}

