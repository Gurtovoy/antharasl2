/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PetInventoryUpdatePacket
extends L2GameServerPacket {
    public static final int UNCHANGED = 0;
    public static final int ADDED = 1;
    public static final int MODIFIED = 2;
    public static final int REMOVED = 3;
    private final List<ItemInfo> _items = new ArrayList<ItemInfo>(1);

    public PetInventoryUpdatePacket addNewItem(ItemInstance item) {
        this.addItem(item).setLastChange(1);
        return this;
    }

    public PetInventoryUpdatePacket addModifiedItem(ItemInstance item) {
        this.addItem(item).setLastChange(2);
        return this;
    }

    public PetInventoryUpdatePacket addRemovedItem(ItemInstance item) {
        this.addItem(item).setLastChange(3);
        return this;
    }

    private ItemInfo addItem(ItemInstance item) {
        ItemInfo info = new ItemInfo(item);
        this._items.add(info);
        return info;
    }

    @Override
    protected final void writeImpl() {
        this.writeH(this._items.size());
        for (ItemInfo temp : this._items) {
            this.writeH(temp.getLastChange());
            this.writeItemInfo(temp);
        }
    }
}

