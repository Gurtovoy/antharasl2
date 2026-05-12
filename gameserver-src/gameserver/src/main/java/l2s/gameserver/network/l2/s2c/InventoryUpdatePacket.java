package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class InventoryUpdatePacket
extends L2GameServerPacket {
    public static final int UNCHANGED = 0;
    public static final int ADDED = 1;
    public static final int MODIFIED = 2;
    public static final int REMOVED = 3;
    private final List<ItemInfo> _items = new ArrayList<ItemInfo>(1);

    public InventoryUpdatePacket addNewItem(Player player, ItemInstance item) {
        this.addItem(player, item).setLastChange(1);
        return this;
    }

    public InventoryUpdatePacket addModifiedItem(Player player, ItemInstance item) {
        this.addItem(player, item).setLastChange(2);
        return this;
    }

    public InventoryUpdatePacket addRemovedItem(Player player, ItemInstance item) {
        this.addItem(player, item).setLastChange(3);
        return this;
    }

    private ItemInfo addItem(Player player, ItemInstance item) {
        ItemInfo info = new ItemInfo(item, item.getTemplate().isBlocked(player, item));
        // Apply costume override: when an active costume should visually replace the chest, write the costume
        // item id as the chest visual id so the local client (and any consumer of this ItemInfo) renders it.
        if (player != null && item.isEquipped() && item.getEquipSlot() == Inventory.PAPERDOLL_CHEST) {
            int costumeVisualId = player.getInventory().getActiveCostumeVisualId();
            if (costumeVisualId > 0) {
                info.setVisualId(costumeVisualId);
            }
        }
        this._items.add(info);
        return info;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(0);
        this.writeD(this._items.size());
        this.writeD(this._items.size());
        for (ItemInfo temp : this._items) {
            this.writeH(temp.getLastChange());
            this.writeItemInfo(temp);
        }
    }
}

