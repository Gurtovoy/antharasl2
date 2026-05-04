package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class TradeUpdatePacket
extends L2GameServerPacket {
    private final int _type;
    private final ItemInfo _item;
    private final long _amount;

    public TradeUpdatePacket(int type, ItemInfo item, long amount) {
        this._type = type;
        this._item = item;
        this._amount = amount;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        this.writeD(1);
        if (this._type == 2) {
            this.writeH(1);
            this.writeC(0);
            this.writeC(0);
            this.writeH(this._amount > 0L && this._item.getItem().isStackable() ? 3 : 2);
            this.writeItemInfo(this._item, this._amount);
        }
    }
}

