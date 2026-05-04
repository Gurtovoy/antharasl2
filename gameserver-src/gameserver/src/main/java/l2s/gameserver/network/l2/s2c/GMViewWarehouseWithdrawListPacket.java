package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class GMViewWarehouseWithdrawListPacket
extends L2GameServerPacket {
    private final int _type;
    private final ItemInstance[] _items;
    private String _charName;
    private long _charAdena;

    public GMViewWarehouseWithdrawListPacket(int type, Player cha) {
        this._type = type;
        this._charName = cha.getName();
        this._charAdena = cha.getWarehouse().getAdena();
        this._items = cha.getWarehouse().getItems();
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeS(this._charName);
            this.writeQ(this._charAdena);
            this.writeD(this._items.length);
        } else if (this._type == 2) {
            this.writeD(this._items.length);
            this.writeD(this._items.length);
            for (ItemInstance temp : this._items) {
                this.writeItemInfo(temp);
                this.writeD(temp.getObjectId());
            }
        }
    }
}

