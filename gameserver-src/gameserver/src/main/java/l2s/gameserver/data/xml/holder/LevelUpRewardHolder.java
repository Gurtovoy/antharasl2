/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntLongMap;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;

public final class LevelUpRewardHolder
extends AbstractHolder {
    private static final LevelUpRewardHolder _instance = new LevelUpRewardHolder();
    private final TIntObjectMap<TIntLongMap> _rewardData = new TIntObjectHashMap();

    public static LevelUpRewardHolder getInstance() {
        return _instance;
    }

    public void addRewardData(int level, TIntLongMap items) {
        this._rewardData.put(level, items);
    }

    public TIntLongMap getRewardData(int level) {
        return (TIntLongMap)this._rewardData.get(level);
    }

    public int size() {
        return this._rewardData.size();
    }

    public void clear() {
        this._rewardData.clear();
    }
}

