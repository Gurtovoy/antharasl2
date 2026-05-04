/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.Warehouse;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class WareHouseDepositListPacket
extends L2GameServerPacket {
    private final int _type;
    private final int _whtype;
    private final long _adena;
    private final List<ItemInfo> _itemList;
    private final int _depositedItemsCount;

    public WareHouseDepositListPacket(int type, Player cha, Warehouse.WarehouseType whtype) {
        this._type = type;
        this._whtype = whtype.ordinal();
        this._adena = cha.getAdena();
        ItemInstance[] items = cha.getInventory().getItems();
        Arrays.sort(items, Warehouse.ItemClassComparator.getInstance());
        this._itemList = new ArrayList<ItemInfo>(items.length);
        for (ItemInstance item : items) {
            if (!item.canBeStored(cha, this._whtype == 1)) continue;
            this._itemList.add(new ItemInfo(item, item.getTemplate().isBlocked(cha, item)));
        }
        switch (whtype) {
            case PRIVATE: {
                this._depositedItemsCount = cha.getWarehouse().getSize();
                break;
            }
            case FREIGHT: {
                this._depositedItemsCount = cha.getFreight().getSize();
                break;
            }
            case CLAN: 
            case CASTLE: {
                this._depositedItemsCount = cha.getClan().getWarehouse().getSize();
                break;
            }
            default: {
                this._depositedItemsCount = 0;
                return;
            }
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        this.writeH(this._whtype);
        if (this._type == 1) {
            this.writeQ(this._adena);
            this.writeH(this._depositedItemsCount);
            this.writeD(0);
            this.writeD(0);
        } else if (this._type == 2) {
            this.writeH(0);
            this.writeD(this._itemList.size());
            for (ItemInfo item : this._itemList) {
                this.writeItemInfo(item);
                this.writeD(item.getObjectId());
            }
        }
    }
}

