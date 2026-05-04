package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class MoveToPawnPacket
extends L2GameServerPacket {
    private int _chaId;
    private int _targetId;
    private int _distance;
    private int _x;
    private int _y;
    private int _z;
    private int _tx;
    private int _ty;
    private int _tz;

    public MoveToPawnPacket(Creature cha, Creature target, int distance) {
        this._chaId = cha.getObjectId();
        this._targetId = target.getObjectId();
        this._distance = distance;
        this._x = cha.getX();
        this._y = cha.getY();
        this._z = cha.getZ();
        this._tx = target.getX();
        this._ty = target.getY();
        this._tz = target.getZ();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._chaId);
        this.writeD(this._targetId);
        this.writeD(this._distance);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
        this.writeD(this._tx);
        this.writeD(this._ty);
        this.writeD(this._tz);
    }
}

