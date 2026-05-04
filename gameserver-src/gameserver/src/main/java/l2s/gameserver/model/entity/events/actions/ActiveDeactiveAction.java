/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class ActiveDeactiveAction
implements EventAction {
    private final boolean _active;
    private final String _name;

    public ActiveDeactiveAction(boolean active, String name) {
        this._active = active;
        this._name = name;
    }

    @Override
    public void call(Event event) {
        event.zoneAction(this._name, this._active);
    }
}

