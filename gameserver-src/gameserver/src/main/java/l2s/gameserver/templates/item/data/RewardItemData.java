package l2s.gameserver.templates.item.data;

import l2s.gameserver.templates.item.data.ChancedItemData;

public class RewardItemData
extends ChancedItemData {
    private final long _maxCount;

    public RewardItemData(int id, long minCount, long maxCount, double chance) {
        super(id, minCount, chance);
        this._maxCount = maxCount;
    }

    public long getMinCount() {
        return this.getCount();
    }

    public long getMaxCount() {
        return this._maxCount;
    }
}

