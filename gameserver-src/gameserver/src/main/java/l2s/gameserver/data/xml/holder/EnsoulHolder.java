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
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.Ensoul;
import l2s.gameserver.templates.item.support.EnsoulFee;

public class EnsoulHolder
extends AbstractHolder {
    private static final EnsoulHolder _instance = new EnsoulHolder();
    private TIntObjectMap<EnsoulFee> _ensoulsFee = new TIntObjectHashMap();
    private TIntObjectMap<Ensoul> _ensouls = new TIntObjectHashMap();

    public static EnsoulHolder getInstance() {
        return _instance;
    }

    public void addEnsoulFee(ItemGrade grade, EnsoulFee ensoulFee) {
        this._ensoulsFee.put(grade.ordinal(), ensoulFee);
    }

    public EnsoulFee getEnsoulFee(ItemGrade grade) {
        return (EnsoulFee)this._ensoulsFee.get(grade.ordinal());
    }

    public void addEnsoul(Ensoul ensoul) {
        this._ensouls.put(ensoul.getId(), ensoul);
    }

    public Ensoul getEnsoul(int id) {
        return (Ensoul)this._ensouls.get(id);
    }

    public int size() {
        return this._ensouls.size();
    }

    public void clear() {
        this._ensoulsFee.clear();
        this._ensouls.clear();
    }
}

