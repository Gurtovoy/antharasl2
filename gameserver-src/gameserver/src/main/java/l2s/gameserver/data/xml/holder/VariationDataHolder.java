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
import l2s.gameserver.templates.item.WeaponFightType;
import l2s.gameserver.templates.item.support.variation.VariationGroup;
import l2s.gameserver.templates.item.support.variation.VariationStone;

public final class VariationDataHolder
extends AbstractHolder {
    private static final VariationDataHolder _instance = new VariationDataHolder();
    private TIntObjectMap<TIntObjectMap<VariationStone>> _stones = new TIntObjectHashMap(WeaponFightType.VALUES.length);
    private TIntObjectMap<VariationGroup> _groups = new TIntObjectHashMap();

    public static VariationDataHolder getInstance() {
        return _instance;
    }

    public void addStone(WeaponFightType weaponType, VariationStone stone) {
        TIntObjectMap stones = (TIntObjectMap)this._stones.get(weaponType.ordinal());
        if (stones == null) {
            stones = new TIntObjectHashMap();
            this._stones.put(weaponType.ordinal(), stones);
        }
        stones.put(stone.getId(), stone);
    }

    public VariationStone getStone(WeaponFightType weaponType, int id) {
        TIntObjectMap stones = (TIntObjectMap)this._stones.get(weaponType.ordinal());
        if (stones == null) {
            return null;
        }
        return (VariationStone)stones.get(id);
    }

    public void addGroup(VariationGroup group) {
        this._groups.put(group.getId(), group);
    }

    public VariationGroup getGroup(int id) {
        return (VariationGroup)this._groups.get(id);
    }

    public int size() {
        return this._stones.size() + this._groups.size();
    }

    public void clear() {
        this._stones.clear();
        this._groups.clear();
    }
}

