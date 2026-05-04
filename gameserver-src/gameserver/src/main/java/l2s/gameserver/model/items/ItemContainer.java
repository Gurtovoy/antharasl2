package l2s.gameserver.model.items;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.math.SafeMath;
import l2s.gameserver.dao.ItemsDAO;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ItemContainer {
    private static final Logger _log = LoggerFactory.getLogger(ItemContainer.class);
    protected static final ItemsDAO _itemsDAO = ItemsDAO.getInstance();
    protected final List<ItemInstance> _items = new ArrayList<ItemInstance>();
    protected final ReadWriteLock lock = new ReentrantReadWriteLock();
    protected final Lock readLock = this.lock.readLock();
    protected final Lock writeLock = this.lock.writeLock();

    protected ItemContainer() {
    }

    public int getSize() {
        return this._items.size();
    }

    public ItemInstance[] getItems() {
        this.readLock();
        try {
            ItemInstance[] itemInstanceArray = this._items.toArray(new ItemInstance[this._items.size()]);
            return itemInstanceArray;
        }
        finally {
            this.readUnlock();
        }
    }

    public boolean containsItem(ItemInstance item) {
        this.readLock();
        try {
            boolean bl = this._items.contains(item);
            return bl;
        }
        finally {
            this.readUnlock();
        }
    }

    public void clear() {
        this.writeLock();
        try {
            this._items.clear();
        }
        finally {
            this.writeUnlock();
        }
    }

    public final void writeLock() {
        this.writeLock.lock();
    }

    public final void writeUnlock() {
        this.writeLock.unlock();
    }

    public final void readLock() {
        this.readLock.lock();
    }

    public final void readUnlock() {
        this.readLock.unlock();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance getItemByObjectId(int objectId) {
        this.readLock();
        try {
            for (int i = 0; i < this._items.size(); ++i) {
                ItemInstance item = this._items.get(i);
                if (item.getObjectId() != objectId) continue;
                ItemInstance itemInstance = item;
                return itemInstance;
            }
        }
        finally {
            this.readUnlock();
        }
        return null;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance getItemByItemId(int itemId) {
        this.readLock();
        try {
            for (int i = 0; i < this._items.size(); ++i) {
                ItemInstance item = this._items.get(i);
                if (item.getItemId() != itemId) continue;
                ItemInstance itemInstance = item;
                return itemInstance;
            }
        }
        finally {
            this.readUnlock();
        }
        return null;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<ItemInstance> getItemsByItemId(int itemId) {
        ArrayList<ItemInstance> result = new ArrayList<ItemInstance>();
        this.readLock();
        try {
            for (int i = 0; i < this._items.size(); ++i) {
                ItemInstance item = this._items.get(i);
                if (item.getItemId() != itemId) continue;
                result.add(item);
            }
        }
        finally {
            this.readUnlock();
        }
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public long getCountOf(int itemId) {
        long count = 0L;
        this.readLock();
        try {
            for (int i = 0; i < this._items.size(); ++i) {
                ItemInstance item = this._items.get(i);
                if (item.getItemId() != itemId) continue;
                count = SafeMath.addAndLimit((long)count, (long)item.getCount());
            }
        }
        finally {
            this.readUnlock();
        }
        return count;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance addItem(int itemId, long count, int enchantLevel) {
        ItemInstance item;
        block8: {
            if (count < 1L) {
                return null;
            }
            this.writeLock();
            try {
                item = this.getItemByItemId(itemId);
                if (item != null && item.isStackable()) {
                    ItemInstance itemInstance = item;
                    synchronized (itemInstance) {
                        item.setCount(SafeMath.addAndLimit((long)item.getCount(), (long)count));
                        this.onModifyItem(item);
                        break block8;
                    }
                }
                item = ItemFunctions.createItem(itemId);
                item.setCount(count);
                item.setEnchantLevel(enchantLevel);
                this._items.add(item);
                this.onAddItem(item);
            }
            finally {
                this.writeUnlock();
            }
        }
        return item;
    }

    public ItemInstance addItem(int itemId, long count) {
        return this.addItem(itemId, count, 0);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance addItem(ItemInstance item) {
        if (item == null) {
            return null;
        }
        if (item.getCount() < 1L) {
            return null;
        }
        ItemInstance result = null;
        this.writeLock();
        try {
            int itemId;
            if (this.getItemByObjectId(item.getObjectId()) != null) {
                ItemInstance itemInstance = null;
                return itemInstance;
            }
            if (item.isStackable() && (result = this.getItemByItemId(itemId = item.getItemId())) != null) {
                ItemInstance itemInstance = result;
                synchronized (itemInstance) {
                    result.setCount(SafeMath.addAndLimit((long)item.getCount(), (long)result.getCount()));
                    this.onModifyItem(result);
                    this.onDestroyItem(item);
                }
            }
            if (result == null) {
                this._items.add(item);
                result = item;
                this.onAddItem(result);
            }
        }
        finally {
            this.writeUnlock();
        }
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance removeItemByObjectId(int objectId, long count) {
        ItemInstance result;
        if (count < 1L) {
            return null;
        }
        this.writeLock();
        try {
            ItemInstance item = this.getItemByObjectId(objectId);
            if (item == null) {
                ItemInstance itemInstance = null;
                return itemInstance;
            }
            ItemInstance itemInstance = item;
            synchronized (itemInstance) {
                result = this.removeItem(item, count);
            }
        }
        finally {
            this.writeUnlock();
        }
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance removeItemByItemId(int itemId, long count) {
        ItemInstance result;
        if (count < 1L) {
            return null;
        }
        this.writeLock();
        try {
            ItemInstance item = this.getItemByItemId(itemId);
            if (item == null) {
                ItemInstance itemInstance = null;
                return itemInstance;
            }
            ItemInstance itemInstance = item;
            synchronized (itemInstance) {
                result = this.removeItem(item, count);
            }
        }
        finally {
            this.writeUnlock();
        }
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance removeItem(ItemInstance item, long count) {
        if (item == null) {
            return null;
        }
        if (count < 1L) {
            return null;
        }
        if (item.getCount() < count) {
            return null;
        }
        this.writeLock();
        try {
            if (!this._items.contains(item)) {
                ItemInstance itemInstance = null;
                return itemInstance;
            }
            if (item.getCount() > count) {
                item.setCount(item.getCount() - count);
                this.onModifyItem(item);
                ItemInstance newItem = new ItemInstance(IdFactory.getInstance().getNextId(), item.getItemId());
                newItem.setCount(count);
                ItemInstance itemInstance = newItem;
                return itemInstance;
            }
            ItemInstance itemInstance = this.removeItem(item);
            return itemInstance;
        }
        finally {
            this.writeUnlock();
        }
    }

    public ItemInstance removeItem(ItemInstance item) {
        if (item == null) {
            return null;
        }
        this.writeLock();
        try {
            if (!this._items.remove(item)) {
                ItemInstance itemInstance = null;
                return itemInstance;
            }
            this.onRemoveItem(item);
            ItemInstance itemInstance = item;
            return itemInstance;
        }
        finally {
            this.writeUnlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean destroyItemByObjectId(int objectId, long count) {
        this.writeLock();
        try {
            ItemInstance item = this.getItemByObjectId(objectId);
            if (item == null) {
                boolean bl = false;
                return bl;
            }
            ItemInstance itemInstance = item;
            synchronized (itemInstance) {
                boolean bl = this.destroyItem(item, count);
                return bl;
            }
        }
        finally {
            this.writeUnlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean destroyItemByItemId(int itemId, long count) {
        this.writeLock();
        try {
            ItemInstance item = this.getItemByItemId(itemId);
            if (item == null) {
                boolean bl = false;
                return bl;
            }
            ItemInstance itemInstance = item;
            synchronized (itemInstance) {
                boolean bl = this.destroyItem(item, count);
                return bl;
            }
        }
        finally {
            this.writeUnlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean destroyItem(ItemInstance item, long count) {
        if (item == null) {
            return false;
        }
        if (count < 1L) {
            return false;
        }
        if (item.getCount() < count) {
            return false;
        }
        this.writeLock();
        try {
            if (!this._items.contains(item)) {
                boolean bl = false;
                return bl;
            }
            if (item.getCount() > count) {
                item.setCount(item.getCount() - count);
                this.onModifyItem(item);
                boolean bl = true;
                return bl;
            }
            boolean bl = this.destroyItem(item);
            return bl;
        }
        finally {
            this.writeUnlock();
        }
    }

    public boolean destroyItem(ItemInstance item) {
        if (item == null) {
            return false;
        }
        this.writeLock();
        try {
            if (!this._items.remove(item)) {
                boolean bl = false;
                return bl;
            }
            this.onRemoveItem(item);
            this.onDestroyItem(item);
            boolean bl = true;
            return bl;
        }
        finally {
            this.writeUnlock();
        }
    }

    protected abstract void onAddItem(ItemInstance var1);

    protected abstract void onModifyItem(ItemInstance var1);

    protected abstract void onRemoveItem(ItemInstance var1);

    protected abstract void onDestroyItem(ItemInstance var1);

    public void checkItems() {
        for (ItemInstance item : this.getItems()) {
            int left;
            if (!item.isTemporalItem() && !item.isFlagLifeTime() && (item.getVisualId() <= 0 || item.getLifeTime() < 0) || (left = item.getTemporalLifeTime()) > 0) continue;
            if (item.getVisualId() > 0) {
                item.setLifeTime(-1);
                item.setVisualId(0);
                item.setAppearanceStoneId(0);
                item.setJdbcState(JdbcEntityState.UPDATED);
                item.update();
                this.onItemVisualTimeEnd(item);
                continue;
            }
            this.destroyItem(item);
            this.onTemporalItemTimeEnd(item);
        }
    }

    protected void onItemVisualTimeEnd(ItemInstance item) {
    }

    protected void onTemporalItemTimeEnd(ItemInstance item) {
    }

    public long getAdena() {
        ItemInstance _adena = this.getItemByItemId(57);
        if (_adena == null) {
            return 0L;
        }
        return _adena.getCount();
    }
}

