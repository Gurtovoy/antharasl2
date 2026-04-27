/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExChangeAttributeItemList
extends L2GameServerPacket {
    private ItemInfo[] _itemsList;
    private int _itemId;

    public ExChangeAttributeItemList(int itemId, ItemInfo[] itemsList) {
        this._itemId = itemId;
        this._itemsList = itemsList;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._itemId);
        this.writeD(this._itemsList.length);
        for (ItemInfo item : this._itemsList) {
            this.writeItemInfo(item);
        }
    }
}

