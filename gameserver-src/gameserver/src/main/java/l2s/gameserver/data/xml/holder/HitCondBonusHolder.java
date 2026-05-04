package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntDoubleMap;
import gnu.trove.map.hash.TIntDoubleHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.base.HitCondBonusType;

public final class HitCondBonusHolder
extends AbstractHolder {
    private static final HitCondBonusHolder _instance = new HitCondBonusHolder();
    private final TIntDoubleMap _bonusList = new TIntDoubleHashMap();

    public static HitCondBonusHolder getInstance() {
        return _instance;
    }

    public void addHitCondBonus(HitCondBonusType type, double value) {
        this._bonusList.put(type.ordinal(), value);
    }

    public double getHitCondBonus(HitCondBonusType type) {
        return this._bonusList.get(type.ordinal());
    }

    public int size() {
        return this._bonusList.size();
    }

    public void clear() {
        this._bonusList.clear();
    }
}

