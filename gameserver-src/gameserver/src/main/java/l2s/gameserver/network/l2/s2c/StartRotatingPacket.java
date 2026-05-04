/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class StartRotatingPacket
extends L2GameServerPacket {
    private int _charId;
    private int _degree;
    private int _side;
    private int _speed;

    public StartRotatingPacket(Creature cha, int degree, int side, int speed) {
        this._charId = cha.getObjectId();
        this._degree = degree;
        this._side = side;
        this._speed = speed;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._charId);
        this.writeD(this._degree);
        this.writeD(this._side);
        this.writeD(this._speed);
    }
}

