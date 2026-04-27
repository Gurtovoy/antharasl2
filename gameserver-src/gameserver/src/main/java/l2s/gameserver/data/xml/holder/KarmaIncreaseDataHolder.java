/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntDoubleMap
 *  gnu.trove.map.hash.TIntDoubleHashMap
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntDoubleMap;
import gnu.trove.map.hash.TIntDoubleHashMap;
import l2s.commons.data.xml.AbstractHolder;

public final class KarmaIncreaseDataHolder
extends AbstractHolder {
    private static final KarmaIncreaseDataHolder _instance = new KarmaIncreaseDataHolder();
    private final TIntDoubleMap _bonusList = new TIntDoubleHashMap();

    public static KarmaIncreaseDataHolder getInstance() {
        return _instance;
    }

    public void addData(int lvl, double bonus) {
        this._bonusList.put(lvl, bonus);
    }

    public double getData(int lvl) {
        return this._bonusList.get(lvl);
    }

    public int size() {
        return this._bonusList.size();
    }

    public void clear() {
        this._bonusList.clear();
    }
}

