package l2s.gameserver.model.items;

import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;

public final class TradeItem
extends ItemInfo {
    private long _price;
    private long _referencePrice;
    private long _currentValue;
    private int _lastRechargeTime;
    private int _rechargeTime;

    public TradeItem() {
    }

    public TradeItem(ItemInstance item) {
        this(item, false);
    }

    public TradeItem(ItemInstance item, boolean isBlocked) {
        super(item, isBlocked);
        this.setReferencePrice(item.getReferencePrice());
    }

    public void setOwnersPrice(long price) {
        this._price = price;
    }

    public long getOwnersPrice() {
        return this._price;
    }

    public void setReferencePrice(long price) {
        this._referencePrice = price;
    }

    public long getReferencePrice() {
        return this._referencePrice;
    }

    public long getStorePrice() {
        return this.getReferencePrice() / 2L;
    }

    public void setCurrentValue(long value) {
        this._currentValue = value;
    }

    public long getCurrentValue() {
        return this._currentValue;
    }

    public void setRechargeTime(int rechargeTime) {
        this._rechargeTime = rechargeTime;
    }

    public int getRechargeTime() {
        return this._rechargeTime;
    }

    public boolean isCountLimited() {
        return this.getCount() > 0L;
    }

    public void setLastRechargeTime(int lastRechargeTime) {
        this._lastRechargeTime = lastRechargeTime;
    }

    public int getLastRechargeTime() {
        return this._lastRechargeTime;
    }

    public TradeItem clone() {
        TradeItem item = new TradeItem();
        item.setOwnerId(this.getOwnerId());
        item.setObjectId(this.getObjectId());
        item.setItemId(this.getItemId());
        item.setCount(this.getCount());
        item.setCustomType1(this.getCustomType1());
        item.setEquipped(this.isEquipped());
        item.setEnchantLevel(this.getEnchantLevel());
        item.setCustomType2(this.getCustomType2());
        item.setVariationStoneId(this.getVariationStoneId());
        item.setVariation1Id(this.getVariation1Id());
        item.setVariation2Id(this.getVariation2Id());
        item.setShadowLifeTime(this.getShadowLifeTime());
        item.setEquipSlot(this.getEquipSlot());
        item.setTemporalLifeTime(this.getTemporalLifeTime());
        item.setEnchantOptions(this.getEnchantOptions());
        item.setAttributeFire(this.getAttributeFire());
        item.setAttributeWater(this.getAttributeWater());
        item.setAttributeWind(this.getAttributeWind());
        item.setAttributeEarth(this.getAttributeEarth());
        item.setAttributeHoly(this.getAttributeHoly());
        item.setAttributeUnholy(this.getAttributeUnholy());
        item.setIsBlocked(this.isBlocked());
        item.setVisualId(this.getVisualId());
        item.setOwnersPrice(this.getOwnersPrice());
        item.setReferencePrice(this.getReferencePrice());
        item.setCurrentValue(this.getCurrentValue());
        item.setLastRechargeTime(this.getLastRechargeTime());
        item.setRechargeTime(this.getRechargeTime());
        return item;
    }
}

