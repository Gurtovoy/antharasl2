/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class MyTargetSelectedPacket
extends L2GameServerPacket {
    private final boolean _success;
    private int _objectId;
    private int _color;
    private final boolean _actionMenu;

    public MyTargetSelectedPacket(int objectId, int color, boolean actionMenu) {
        this._success = true;
        this._objectId = objectId;
        this._color = color;
        this._actionMenu = actionMenu;
    }

    public MyTargetSelectedPacket(int objectId, int color) {
        this(objectId, color, false);
    }

    public MyTargetSelectedPacket(Player player, GameObject target, boolean actionMenu) {
        this._success = true;
        this._objectId = target.getObjectId();
        this._color = target.isCreature() ? player.getLevel() - ((Creature)target).getLevel() : 0;
        this._actionMenu = actionMenu;
    }

    public MyTargetSelectedPacket(Player player, GameObject target) {
        this(player, target, false);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._success ? 1 : 0);
        if (this._success) {
            this.writeD(this._objectId);
            this.writeH(this._color);
            this.writeD(this._actionMenu ? 3 : 0);
        }
    }
}

