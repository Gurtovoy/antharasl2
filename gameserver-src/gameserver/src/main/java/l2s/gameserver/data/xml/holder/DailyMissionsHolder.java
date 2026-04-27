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
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.templates.dailymissions.DailyMissionTemplate;
import l2s.gameserver.templates.dailymissions.DailyRewardTemplate;

public final class DailyMissionsHolder
extends AbstractHolder {
    private static final DailyMissionsHolder _instance = new DailyMissionsHolder();
    private final TIntObjectMap<DailyMissionTemplate> _missions = new TIntObjectHashMap();
    private final TIntObjectMap<Set<DailyMissionTemplate>> _missionsByClassId = new TIntObjectHashMap(ClassId.VALUES.length);

    public static DailyMissionsHolder getInstance() {
        return _instance;
    }

    public void addMission(DailyMissionTemplate mission) {
        this._missions.put(mission.getId(), mission);
        for (DailyRewardTemplate reward : mission.getRewards()) {
            for (ClassId classId : ClassId.VALUES) {
                if (!reward.containsClassId(classId.getId())) continue;
                HashSet<DailyMissionTemplate> missionsByClassId = (HashSet<DailyMissionTemplate>)this._missionsByClassId.get(classId.getId());
                if (missionsByClassId == null) {
                    missionsByClassId = new HashSet<DailyMissionTemplate>();
                    this._missionsByClassId.put(classId.getId(), missionsByClassId);
                }
                missionsByClassId.add(mission);
            }
        }
    }

    public DailyMissionTemplate getMission(int id) {
        return (DailyMissionTemplate)this._missions.get(id);
    }

    public Collection<DailyMissionTemplate> getMissions() {
        return this._missions.valueCollection();
    }

    public Collection<DailyMissionTemplate> getMissions(int classId) {
        Collection missions = (Collection)this._missionsByClassId.get(classId);
        if (missions == null) {
            return Collections.emptyList();
        }
        return missions;
    }

    public int size() {
        return this._missions.size();
    }

    public void clear() {
        this._missions.clear();
    }
}

