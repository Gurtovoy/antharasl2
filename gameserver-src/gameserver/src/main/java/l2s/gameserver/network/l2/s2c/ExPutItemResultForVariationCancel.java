package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.VariationUtils;

public class ExPutItemResultForVariationCancel
extends L2GameServerPacket {
    private int _itemObjectId;
    private int _itemId;
    private int _aug1;
    private int _aug2;
    private long _price;

    public ExPutItemResultForVariationCancel(ItemInstance item) {
        this._itemObjectId = item.getObjectId();
        this._itemId = item.getItemId();
        this._aug1 = item.getVariation1Id();
        this._aug2 = item.getVariation2Id();
        this._price = VariationUtils.getRemovePrice(item);
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._itemObjectId);
        this.writeD(this._itemId);
        this.writeD(this._aug1);
        this.writeD(this._aug2);
        this.writeQ(this._price);
        this.writeD(1);
    }
}

