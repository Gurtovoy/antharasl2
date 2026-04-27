/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExResponseCommissionBuyItem
extends L2GameServerPacket {
    public static final ExResponseCommissionBuyItem FAILED = new ExResponseCommissionBuyItem();
    private int _code;
    private int _itemId;
    private long _count;

    public ExResponseCommissionBuyItem() {
        this._code = 0;
    }

    public ExResponseCommissionBuyItem(int itemId, long count) {
        this._code = 1;
        this._itemId = itemId;
        this._count = count;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._code);
        if (this._code == 0) {
            return;
        }
        this.writeD(0);
        this.writeD(this._itemId);
        this.writeQ(this._count);
    }
}

