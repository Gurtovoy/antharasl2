/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.Warehouse;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class WareHouseWithdrawListPacket
extends L2GameServerPacket {
    private final int _type;
    private final long _adena;
    private List<ItemInfo> _itemList = Collections.emptyList();
    private final int _whType;
    private final int _inventoryUsedSlots;

    public WareHouseWithdrawListPacket(int type, Player player, Warehouse.WarehouseType whType) {
        ItemInstance[] items;
        this._type = type;
        this._adena = player.getAdena();
        this._whType = whType.ordinal();
        this._inventoryUsedSlots = player.getInventory().getSize();
        switch (whType) {
            case PRIVATE: {
                items = player.getWarehouse().getItems();
                break;
            }
            case FREIGHT: {
                items = player.getFreight().getItems();
                break;
            }
            case CLAN: 
            case CASTLE: {
                items = player.getClan().getWarehouse().getItems();
                break;
            }
            default: {
                return;
            }
        }
        this._itemList = new ArrayList<ItemInfo>(items.length);
        Arrays.sort(items, Warehouse.ItemClassComparator.getInstance());
        for (ItemInstance item : items) {
            this._itemList.add(new ItemInfo(item));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        this.writeH(this._whType);
        if (this._type == 1) {
            this.writeQ(this._adena);
            this.writeD(this._inventoryUsedSlots);
            this.writeD(this._itemList.size());
        } else if (this._type == 2) {
            if (this._whType == 1 || this._whType == 2) {
                if (this._itemList.size() > 0) {
                    this.writeD(this._itemList.get(0).getItemId());
                } else {
                    this.writeD(0);
                }
            }
            if (this._whType == 2) {
                this.writeD(0);
            }
            this.writeD(this._itemList.size());
            this.writeD(this._itemList.size());
            for (ItemInfo item : this._itemList) {
                this.writeItemInfo(item);
                this.writeD(item.getObjectId());
                this.writeD(0);
                this.writeD(0);
            }
        }
    }
}

