/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.ArmorSet;

public final class ArmorSetsHolder
extends AbstractHolder {
    private static final ArmorSetsHolder _instance = new ArmorSetsHolder();
    private final TIntObjectHashMap<List<ArmorSet>> _armorSets = new TIntObjectHashMap();

    public static ArmorSetsHolder getInstance() {
        return _instance;
    }

    public void addArmorSet(ArmorSet armorset) {
        List<ArmorSet> sets;
        for (int id : armorset.getChestIds()) {
            sets = (ArrayList<ArmorSet>)this._armorSets.get(id);
            if (sets == null) {
                sets = new ArrayList<ArmorSet>();
            }
            sets.add(armorset);
            this._armorSets.put(id, sets);
        }
        for (int id : armorset.getLegIds()) {
            sets = (List)this._armorSets.get(id);
            if (sets == null) {
                sets = new ArrayList();
            }
            sets.add(armorset);
            this._armorSets.put(id, sets);
        }
        for (int id : armorset.getHeadIds()) {
            sets = (List)this._armorSets.get(id);
            if (sets == null) {
                sets = new ArrayList();
            }
            sets.add(armorset);
            this._armorSets.put(id, sets);
        }
        for (int id : armorset.getGlovesIds()) {
            sets = (List)this._armorSets.get(id);
            if (sets == null) {
                sets = new ArrayList();
            }
            sets.add(armorset);
            this._armorSets.put(id, sets);
        }
        for (int id : armorset.getFeetIds()) {
            sets = (List)this._armorSets.get(id);
            if (sets == null) {
                sets = new ArrayList();
            }
            sets.add(armorset);
            this._armorSets.put(id, sets);
        }
        for (int id : armorset.getShieldIds()) {
            sets = (List)this._armorSets.get(id);
            if (sets == null) {
                sets = new ArrayList();
            }
            sets.add(armorset);
            this._armorSets.put(id, sets);
        }
    }

    public List<ArmorSet> getArmorSets(int id) {
        return (List)this._armorSets.get(id);
    }

    public int size() {
        return this._armorSets.size();
    }

    public void clear() {
        this._armorSets.clear();
    }
}

