/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExTryMixCube
extends L2GameServerPacket {
    public static final L2GameServerPacket FAIL = new ExTryMixCube(6);
    private final int _result;
    private final int _itemId;
    private final long _itemCount;

    public ExTryMixCube(int result) {
        this._result = result;
        this._itemId = 0;
        this._itemCount = 0L;
    }

    public ExTryMixCube(int itemId, long itemCount) {
        this._result = 0;
        this._itemId = itemId;
        this._itemCount = itemCount;
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._result);
        this.writeD(1);
        this.writeC(0);
        this.writeD(this._itemId);
        this.writeQ(this._itemCount);
    }
}

