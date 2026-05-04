package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPrivateStoreSellingResult
extends L2GameServerPacket {
    private final int _itemObjId;
    private final long _itemCount;
    private final String _buyerName;

    public ExPrivateStoreSellingResult(int itemObjId, long itemCount, String buyerName) {
        this._itemObjId = itemObjId;
        this._itemCount = itemCount;
        this._buyerName = buyerName;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._itemObjId);
        this.writeQ(this._itemCount);
        this.writeS(this._buyerName);
    }
}

