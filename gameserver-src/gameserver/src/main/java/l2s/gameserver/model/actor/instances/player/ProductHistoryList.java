/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.ArrayList;
import java.util.Collection;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.ProductHistoryDAO;
import l2s.gameserver.data.xml.holder.ProductDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ProductHistoryItem;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExBR_NewIConCashBtnWnd;
import l2s.gameserver.templates.item.product.ProductItem;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public class ProductHistoryList {
    protected final ReadWriteLock lock = new ReentrantReadWriteLock();
    protected final Lock readLock = this.lock.readLock();
    protected final Lock writeLock = this.lock.writeLock();
    private IntObjectMap<ProductHistoryItem> _productHistoryMap = new HashIntObjectMap(0);
    private final Player _owner;
    private ScheduledFuture<?> _limitRefreshTask = null;

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

    public ProductHistoryList(Player owner) {
        this._owner = owner;
    }

    public void restore() {
        if (Config.EX_USE_PRIME_SHOP) {
            ProductHistoryDAO.getInstance().select(this._owner, this._productHistoryMap);
            this.refreshLimits();
        }
    }

    public boolean add(ProductHistoryItem historyItem) {
        if (!Config.EX_USE_PRIME_SHOP) {
            return false;
        }
        if (historyItem.getProduct().getLimit() > 0) {
            if (!ProductHistoryDAO.getInstance().replace(this._owner, historyItem)) {
                return false;
            }
            this.writeLock();
            try {
                this._productHistoryMap.put(historyItem.getProduct().getId(), historyItem);
            }
            finally {
                this.writeUnlock();
            }
        }
        return true;
    }

    public ProductHistoryItem get(int productId) {
        this.readLock();
        try {
            ProductHistoryItem productHistoryItem = (ProductHistoryItem)this._productHistoryMap.get(productId);
            return productHistoryItem;
        }
        finally {
            this.readUnlock();
        }
    }

    public boolean remove(int productId) {
        boolean removed;
        this.writeLock();
        try {
            removed = this._productHistoryMap.remove(productId) != null;
        }
        finally {
            this.writeUnlock();
        }
        if (removed) {
            ProductHistoryDAO.getInstance().delete(this._owner, productId);
            return true;
        }
        return false;
    }

    public boolean contains(int productId) {
        this.readLock();
        try {
            boolean bl = this._productHistoryMap.containsKey(productId);
            return bl;
        }
        finally {
            this.readUnlock();
        }
    }

    public int size() {
        this.readLock();
        try {
            int n = this._productHistoryMap.size();
            return n;
        }
        finally {
            this.readUnlock();
        }
    }

    public ProductHistoryItem[] values() {
        this.readLock();
        try {
            ProductHistoryItem[] productHistoryItemArray = (ProductHistoryItem[])this._productHistoryMap.values(new ProductHistoryItem[this._productHistoryMap.size()]);
            return productHistoryItemArray;
        }
        finally {
            this.readUnlock();
        }
    }

    public Collection<ProductItem> productValues() {
        ArrayList<ProductItem> products = new ArrayList<ProductItem>();
        for (ProductHistoryItem item : this.values()) {
            products.add(item.getProduct());
        }
        return products;
    }

    public boolean isEmpty() {
        this.readLock();
        try {
            boolean bl = this._productHistoryMap.isEmpty();
            return bl;
        }
        finally {
            this.readUnlock();
        }
    }

    public String toString() {
        return "ProductHistoryList[owner=" + this._owner.getName() + "]";
    }

    
    public void startTask() {
        if (!Config.EX_USE_PRIME_SHOP) {
            return;
        }
        this.stopTask();
        long limitRefreshTime = 0L;
        this.writeLock();
        try {
            for (ProductHistoryItem item : this.values()) {
                SchedulingPattern pattern;
                if (item.getProduct().getLimit() == -1 || (pattern = item.getProduct().getLimitRefreshPattern()) == null) continue;
                long time = pattern.next((long)item.getLastPurchaseTime() * 1000L);
                if (time <= System.currentTimeMillis()) {
                    this.remove(item.getProduct().getId());
                    continue;
                }
                if (limitRefreshTime > 0L && limitRefreshTime < time) continue;
                limitRefreshTime = time;
            }
        }
        finally {
            this.writeUnlock();
        }
        long delay = limitRefreshTime - System.currentTimeMillis();
        if (delay < 0L) {
            return;
        }
        this._limitRefreshTask = ThreadPoolManager.getInstance().schedule(() -> {
            this.refreshLimits();
            this._owner.sendPacket((IBroadcastPacket)new ExBR_NewIConCashBtnWnd(this._owner));
            this.startTask();
        }, delay);
    }

    public void stopTask() {
        if (this._limitRefreshTask != null) {
            this._limitRefreshTask.cancel(false);
            this._limitRefreshTask = null;
        }
    }

    
    private void refreshLimits() {
        this.writeLock();
        try {
            for (ProductHistoryItem item : this.values()) {
                long time;
                SchedulingPattern pattern;
                if (item.getProduct().getLimit() == -1 || (pattern = item.getProduct().getLimitRefreshPattern()) == null || (time = pattern.next((long)item.getLastPurchaseTime() * 1000L)) > System.currentTimeMillis()) continue;
                this.remove(item.getProduct().getId());
            }
        }
        finally {
            this.writeUnlock();
        }
    }

    
    public void onPurchaseProduct(ProductItem product, int count) {
        this.writeLock();
        try {
            ProductHistoryItem item = this.get(product.getId());
            if (item != null) {
                item.setPurchasedCount(item.getPurchasedCount() + count);
                item.setLastPurchaseTime((int)(System.currentTimeMillis() / 1000L));
            } else {
                item = new ProductHistoryItem(product, count, (int)(System.currentTimeMillis() / 1000L));
            }
            this.add(item);
            this.startTask();
        }
        finally {
            this.writeUnlock();
        }
    }

    public boolean isExpended(int productId) {
        ProductHistoryItem item = this.get(productId);
        if (item != null) {
            return item.isExpended();
        }
        return false;
    }

    public boolean haveGifts() {
        if (!Config.EX_USE_PRIME_SHOP) {
            return false;
        }
        for (ProductItem product : ProductDataHolder.getInstance().getProductsOnSale(this._owner)) {
            ProductHistoryItem historyItem;
            if (product.getLimit() == -1 || product.getPrice() > 0 || product.getSilverCoinCount() > 0 || product.getGoldCoinCount() > 0 || (historyItem = this.get(product.getId())) != null && historyItem.isExpended()) continue;
            return true;
        }
        return false;
    }
}

