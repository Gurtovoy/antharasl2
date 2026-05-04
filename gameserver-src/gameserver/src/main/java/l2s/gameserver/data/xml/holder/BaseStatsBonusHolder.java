/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.BaseStatsBonus;

public final class BaseStatsBonusHolder
extends AbstractHolder {
    private static final BaseStatsBonusHolder _instance = new BaseStatsBonusHolder();
    private final TIntObjectMap<BaseStatsBonus> _bonuses = new TIntObjectHashMap();

    public static BaseStatsBonusHolder getInstance() {
        return _instance;
    }

    public void addBaseStatsBonus(int value, BaseStatsBonus bonus) {
        this._bonuses.put(value, bonus);
    }

    public BaseStatsBonus getBaseStatsBonus(int value) {
        return (BaseStatsBonus)this._bonuses.get(value);
    }

    public int size() {
        return this._bonuses.size();
    }

    public void clear() {
        this._bonuses.clear();
    }
}

