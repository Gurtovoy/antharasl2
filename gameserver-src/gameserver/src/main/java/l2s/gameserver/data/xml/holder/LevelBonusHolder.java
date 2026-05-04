/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntDoubleMap;
import gnu.trove.map.hash.TIntDoubleHashMap;
import l2s.commons.data.xml.AbstractHolder;

public final class LevelBonusHolder
extends AbstractHolder {
    private static final LevelBonusHolder _instance = new LevelBonusHolder();
    private final TIntDoubleMap _bonusList = new TIntDoubleHashMap();

    public static LevelBonusHolder getInstance() {
        return _instance;
    }

    public void addLevelBonus(int lvl, double bonus) {
        this._bonusList.put(lvl, bonus);
    }

    public double getLevelBonus(int lvl) {
        return this._bonusList.get(lvl);
    }

    public int size() {
        return this._bonusList.size();
    }

    public void clear() {
        this._bonusList.clear();
    }
}

