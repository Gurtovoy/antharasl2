/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.actions;

import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class SpawnDespawnAction
implements EventAction {
    private final boolean _spawn;
    private final String _name;

    public SpawnDespawnAction(String name, boolean spawn) {
        this._spawn = spawn;
        this._name = name;
    }

    @Override
    public void call(Event event) {
        event.spawnAction(this._name, this._spawn);
    }
}

