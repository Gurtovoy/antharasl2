/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.actor.instances.player;

import l2s.gameserver.templates.item.product.ProductItem;

public class ProductHistoryItem {
    private final ProductItem _product;
    private int _purchasedCount;
    private int _lastPurchaseTime;

    public ProductHistoryItem(ProductItem product, int purchasedCount, int lastPurchaseTime) {
        this._product = product;
        this._purchasedCount = purchasedCount;
        this._lastPurchaseTime = lastPurchaseTime;
    }

    public ProductItem getProduct() {
        return this._product;
    }

    public int getPurchasedCount() {
        return this._purchasedCount;
    }

    public void setPurchasedCount(int value) {
        this._purchasedCount = value;
    }

    public int getLastPurchaseTime() {
        return this._lastPurchaseTime;
    }

    public void setLastPurchaseTime(int value) {
        this._lastPurchaseTime = value;
    }

    public boolean isExpended() {
        return this.getProduct().getLimit() <= this.getPurchasedCount();
    }

    public String toString() {
        return "ProductHistoryItem[product ID=" + this._product.getId() + ", purchased count=" + this._purchasedCount + ", last purchase time=" + this._lastPurchaseTime + "]";
    }
}

