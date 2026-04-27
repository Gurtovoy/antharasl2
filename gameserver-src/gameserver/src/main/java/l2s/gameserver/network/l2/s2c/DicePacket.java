/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class DicePacket
extends L2GameServerPacket {
    private int _playerId;
    private int _itemId;
    private int _number;
    private int _x;
    private int _y;
    private int _z;

    public DicePacket(int playerId, int itemId, int number, int x, int y, int z) {
        this._playerId = playerId;
        this._itemId = itemId;
        this._number = number;
        this._x = x;
        this._y = y;
        this._z = z;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playerId);
        this.writeD(this._itemId);
        this.writeD(this._number);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
    }
}

