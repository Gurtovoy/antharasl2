/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class RespawnAction
implements EventAction {
    private final String _name;

    public RespawnAction(String name) {
        this._name = name;
    }

    @Override
    public void call(Event event) {
        event.respawnAction(this._name);
    }
}

