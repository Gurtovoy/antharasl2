/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class FinishRotatingPacket
extends L2GameServerPacket {
    private int _charId;
    private int _degree;
    private int _speed;

    public FinishRotatingPacket(Creature player, int degree, int speed) {
        this._charId = player.getObjectId();
        this._degree = degree;
        this._speed = speed;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._charId);
        this.writeD(this._degree);
        this.writeD(this._speed);
        this.writeD(0);
    }
}

