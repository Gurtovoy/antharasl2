/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class TeleportPlayersAction
implements EventAction {
    private String _name;

    public TeleportPlayersAction(String name) {
        this._name = name;
    }

    @Override
    public void call(Event event) {
        event.teleportPlayers(this._name);
    }
}

