package l2s.gameserver.templates.dailymissions;

import gnu.trove.set.TIntSet;
import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.templates.item.data.ItemData;

public class DailyRewardTemplate {
    private final TIntSet _classIds;
    private final List<ItemData> _rewardItems = new ArrayList<ItemData>();

    public DailyRewardTemplate(TIntSet classIds) {
        this._classIds = classIds;
    }

    public boolean containsClassId(int classId) {
        if (this._classIds == null) {
            return true;
        }
        return this._classIds.contains(classId);
    }

    public void addRewardItem(ItemData item) {
        this._rewardItems.add(item);
    }

    public ItemData[] getRewardItems() {
        return this._rewardItems.toArray(new ItemData[this._rewardItems.size()]);
    }
}

