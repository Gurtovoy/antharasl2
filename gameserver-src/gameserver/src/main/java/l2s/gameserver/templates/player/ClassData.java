/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.hash.TIntObjectHashMap
 */
package l2s.gameserver.templates.player;

import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.gameserver.templates.player.HpMpCpData;

public class ClassData {
    private final int _classId;
    private final TIntObjectHashMap<HpMpCpData> _hpMpCpData = new TIntObjectHashMap();

    public ClassData(int classId) {
        this._classId = classId;
    }

    public void addHpMpCpData(int level, double hp, double mp, double cp) {
        this._hpMpCpData.put(level, new HpMpCpData(hp, mp, cp));
    }

    public HpMpCpData getHpMpCpData(int level) {
        return (HpMpCpData)this._hpMpCpData.get(level);
    }

    public int getClassId() {
        return this._classId;
    }
}

