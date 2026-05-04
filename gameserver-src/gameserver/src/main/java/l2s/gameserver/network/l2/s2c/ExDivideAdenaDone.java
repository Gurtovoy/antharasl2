/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExDivideAdenaDone
extends L2GameServerPacket {
    private final int _friendsCount;
    private final long _count;
    private final long _dividedCount;
    private final String _name;

    public ExDivideAdenaDone(int friendsCount, long count, long dividedCount, String name) {
        this._friendsCount = friendsCount;
        this._count = count;
        this._dividedCount = dividedCount;
        this._name = name;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(1);
        this.writeC(0);
        this.writeD(this._friendsCount);
        this.writeQ(this._dividedCount);
        this.writeQ(this._count);
        this.writeS(this._name);
    }
}

