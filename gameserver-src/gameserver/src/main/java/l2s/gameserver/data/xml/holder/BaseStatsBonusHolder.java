/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.data.xml.AbstractHolder
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

