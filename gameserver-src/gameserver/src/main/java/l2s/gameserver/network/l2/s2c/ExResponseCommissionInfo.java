package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExResponseCommissionInfo
extends L2GameServerPacket {
    private ItemInstance _item;

    public ExResponseCommissionInfo(ItemInstance item) {
        this._item = item;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._item.getItemId());
        this.writeD(this._item.getObjectId());
        this.writeQ(this._item.getCount());
        this.writeQ(0L);
        this.writeD(0);
    }
}

