/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.product;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.templates.item.product.ProductItemComponent;

public class ProductItem
implements Comparable<ProductItem> {
    public static final long NOT_LIMITED_START_TIME = 315547200000L;
    public static final long NOT_LIMITED_END_TIME = 2127445200000L;
    public static final SchedulingPattern DEFAULT_LIMIT_REFRESH_PATTERN = new SchedulingPattern("30 6 * * *");
    private final int _id;
    private final int _category;
    private final int _price;
    private final int _silverCoinCount;
    private final int _goldCoinCount;
    private final int _minVipLevel;
    private final int _maxVipLevel;
    private final int _limit;
    private final SchedulingPattern _limitRefreshPattern;
    private final boolean _isHot;
    private final boolean _isNew;
    private final int _locationId;
    private final long _startTimeSale;
    private final long _endTimeSale;
    private final boolean _onSale;
    private final List<ProductItemComponent> _components = new ArrayList<ProductItemComponent>();

    public ProductItem(int id, int category, int price, int silverCoinCount, int goldCoinCount, int minVipLevel, int maxVipLevel, int limit, String limitRefreshPattern, boolean isHot, boolean isNew, long startTimeSale, long endTimeSale, boolean onSale, int locationId) {
        this._id = id;
        this._category = category;
        this._price = price;
        this._silverCoinCount = silverCoinCount;
        this._goldCoinCount = goldCoinCount;
        this._minVipLevel = minVipLevel;
        this._maxVipLevel = maxVipLevel;
        this._limit = limit;
        this._limitRefreshPattern = limitRefreshPattern == null ? DEFAULT_LIMIT_REFRESH_PATTERN : (limitRefreshPattern.equals("-1") ? null : new SchedulingPattern(limitRefreshPattern));
        this._isHot = isHot;
        this._isNew = isNew;
        this._onSale = onSale;
        this._startTimeSale = startTimeSale > 0L ? startTimeSale : 315547200000L;
        this._endTimeSale = endTimeSale > 0L ? endTimeSale : 2127445200000L;
        this._locationId = locationId;
    }

    public void addComponent(ProductItemComponent component) {
        this._components.add(component);
    }

    public List<ProductItemComponent> getComponents() {
        return this._components;
    }

    public int getId() {
        return this._id;
    }

    public int getCategory() {
        return this._category;
    }

    public int getPrice() {
        return this._price;
    }

    public int getSilverCoinCount() {
        return this._silverCoinCount;
    }

    public int getGoldCoinCount() {
        return this._goldCoinCount;
    }

    public int getMinVipLevel() {
        return this._minVipLevel;
    }

    public int getMaxVipLevel() {
        return this._maxVipLevel;
    }

    public int getLimit() {
        return this._limit;
    }

    public SchedulingPattern getLimitRefreshPattern() {
        return this._limitRefreshPattern;
    }

    public boolean isHot() {
        return this._isHot;
    }

    public boolean isNew() {
        return this._isNew;
    }

    public int getLocationId() {
        return this._locationId;
    }

    public long getStartTimeSale() {
        return this._startTimeSale;
    }

    public long getEndTimeSale() {
        return this._endTimeSale;
    }

    public boolean isOnSale() {
        return this._onSale && (this._limit == -1 || this._limit > 0);
    }

    @Override
    public int compareTo(ProductItem o) {
        return this.getId() - o.getId();
    }
}

