/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDailyMissionsDAO;
import l2s.gameserver.data.xml.holder.DailyMissionsHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.DailyMission;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.templates.dailymissions.DailyMissionStatus;
import l2s.gameserver.templates.dailymissions.DailyMissionTemplate;
import l2s.gameserver.templates.dailymissions.DailyRewardTemplate;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DailyMissionList {
    private static final Logger _log = LoggerFactory.getLogger(DailyMissionList.class);
    private final Player _owner;
    private final Map<Integer, DailyMission> _missions = new HashMap<Integer, DailyMission>();

    public DailyMissionList(Player owner) {
        this._owner = owner;
    }

    public void restore() {
        CharacterDailyMissionsDAO.getInstance().restore(this._owner, this._missions);
    }

    public void store() {
        CharacterDailyMissionsDAO.getInstance().store(this._owner, this.values());
    }

    public Collection<DailyMission> values() {
        return this._missions.values();
    }

    public DailyMission get(DailyMissionTemplate missionTemplate) {
        DailyMission mission = this._missions.get(missionTemplate.getId());
        if (mission == null) {
            mission = new DailyMission(this._owner, missionTemplate, false, 0);
            this._missions.put(mission.getId(), mission);
        }
        return mission;
    }

    public Collection<DailyMissionTemplate> getAvailableMissions() {
        if (!Config.EX_USE_TO_DO_LIST) {
            return Collections.emptyList();
        }
        return DailyMissionsHolder.getInstance().getMissions(this._owner.getBaseClassId());
    }

    public boolean complete(int missionId) {
        DailyMissionTemplate missionTemplate = DailyMissionsHolder.getInstance().getMission(missionId);
        if (missionTemplate == null) {
            return false;
        }
        DailyMission mission = this.get(missionTemplate);
        if (mission.getStatus() != DailyMissionStatus.AVAILABLE) {
            return false;
        }
        if (this._owner.getWeightPenalty() >= 3 || (double)this._owner.getInventoryLimit() * 0.8 < (double)this._owner.getInventory().getSize()) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
            return false;
        }
        int missionValue = mission.getValue();
        mission.setValue((int)(System.currentTimeMillis() / 1000L));
        mission.setCompleted(true);
        if (!CharacterDailyMissionsDAO.getInstance().insert(this._owner, mission)) {
            mission.setValue(missionValue);
            mission.setCompleted(false);
            return false;
        }
        for (DailyRewardTemplate reward : missionTemplate.getRewards()) {
            if (!reward.containsClassId(this._owner.getBaseClassId())) continue;
            for (ItemData item : reward.getRewardItems()) {
                ItemFunctions.addItem(this._owner, item.getId(), item.getCount());
            }
        }
        return true;
    }

    public String toString() {
        return "DailyMissionList[owner=" + this._owner.getName() + "]";
    }
}

