/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ChangeWaitTypePacket
extends L2GameServerPacket {
    private int _objectId;
    private int _moveType;
    private int _x;
    private int _y;
    private int _z;
    public static final int WT_SITTING = 0;
    public static final int WT_STANDING = 1;
    public static final int WT_START_FAKEDEATH = 2;
    public static final int WT_STOP_FAKEDEATH = 3;

    public ChangeWaitTypePacket(Creature cha, int newMoveType) {
        this._objectId = cha.getObjectId();
        this._moveType = newMoveType;
        this._x = cha.getX();
        this._y = cha.getY();
        this._z = cha.getZ();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._moveType);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
    }
}

