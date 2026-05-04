package l2s.gameserver.model.items;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.model.items.ItemContainer;
import l2s.gameserver.model.items.ItemInstance;

public abstract class Warehouse
extends ItemContainer {
    protected final int _ownerId;

    protected Warehouse(int ownerId) {
        this._ownerId = ownerId;
    }

    public int getOwnerId() {
        return this._ownerId;
    }

    public abstract ItemInstance.ItemLocation getItemLocation();

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public ItemInstance[] getItems() {
        ArrayList<ItemInstance> result = new ArrayList<ItemInstance>();
        this.readLock();
        try {
            for (ItemInstance item : this._items) {
                result.add(item);
            }
        }
        finally {
            this.readUnlock();
        }
        return result.toArray(new ItemInstance[result.size()]);
    }

    public long getCountOfAdena() {
        return this.getCountOf(57);
    }

    @Override
    protected void onAddItem(ItemInstance item) {
        item.setOwnerId(this.getOwnerId());
        item.setLocation(this.getItemLocation());
        item.setLocData(0);
        if (item.getJdbcState().isSavable()) {
            item.save();
        } else {
            item.setJdbcState(JdbcEntityState.UPDATED);
            item.update();
        }
    }

    @Override
    protected void onModifyItem(ItemInstance item) {
        item.setJdbcState(JdbcEntityState.UPDATED);
        item.update();
    }

    @Override
    protected void onRemoveItem(ItemInstance item) {
        item.setLocData(-1);
    }

    @Override
    protected void onDestroyItem(ItemInstance item) {
        item.setCount(0L);
        item.delete();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restore() {
        int ownerId = this.getOwnerId();
        this.writeLock();
        try {
            Collection<ItemInstance> items = _itemsDAO.getItemsByOwnerIdAndLoc(ownerId, this.getItemLocation());
            for (ItemInstance item : items) {
                this._items.add(item);
            }
        }
        finally {
            this.writeUnlock();
        }
        this.checkItems();
    }

    public static class ItemClassComparator
    implements Comparator<ItemInstance> {
        private static final Comparator<ItemInstance> instance = new ItemClassComparator();

        public static final Comparator<ItemInstance> getInstance() {
            return instance;
        }

        @Override
        public int compare(ItemInstance o1, ItemInstance o2) {
            if (o1 == null || o2 == null) {
                return 0;
            }
            int diff = o1.getExType().mask() - o2.getExType().mask();
            if (diff == 0) {
                diff = o1.getGrade().ordinal() - o2.getGrade().ordinal();
            }
            if (diff == 0) {
                diff = o1.getItemId() - o2.getItemId();
            }
            if (diff == 0) {
                diff = o1.getEnchantLevel() - o2.getEnchantLevel();
            }
            return diff;
        }
    }

    public static enum WarehouseType {
        NONE,
        PRIVATE,
        CLAN,
        CASTLE,
        FREIGHT;

    }
}

