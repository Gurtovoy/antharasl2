/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.instances;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.StaticObjectInstance;
import l2s.gameserver.templates.StaticObjectTemplate;

public class ChairInstance
extends StaticObjectInstance {
    private Player _seatedPlayer = null;

    public ChairInstance(int objectId, StaticObjectTemplate template) {
        super(objectId, template);
    }

    public Player getSeatedPlayer() {
        return this._seatedPlayer;
    }

    public void setSeatedPlayer(Player player) {
        this._seatedPlayer = player;
    }

    public boolean canSit(Player player) {
        if (this._seatedPlayer != null && this._seatedPlayer.getChairObject() == this) {
            return false;
        }
        return player.getRealDistance3D(this) <= 80;
    }
}

