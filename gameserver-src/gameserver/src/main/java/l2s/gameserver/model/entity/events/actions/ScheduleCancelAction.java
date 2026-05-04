/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class ScheduleCancelAction
implements EventAction {
    private final String _name;
    private final boolean _schedule;

    public ScheduleCancelAction(String name, boolean schedule) {
        this._name = name;
        this._schedule = schedule;
    }

    @Override
    public void call(Event event) {
        event.taskAction(this._name, this._schedule);
    }
}

