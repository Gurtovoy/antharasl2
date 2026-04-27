/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.time.cron.SchedulingPattern
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.DailyMission;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.dailymissions.DailyMissionTemplate;

public class ExOneDayReceiveRewardList
extends L2GameServerPacket {
    private static final SchedulingPattern DAILY_REUSE_PATTERN = new SchedulingPattern("30 6 * * *");
    private static final SchedulingPattern WEEKLY_REUSE_PATTERN = new SchedulingPattern("30 6 * * 1");
    private static final SchedulingPattern MONTHLY_REUSE_PATTERN = new SchedulingPattern("30 6 1 * *");
    private final int _dayRemainTime;
    private final int _weekRemainTime;
    private final int _monthRemainTime;
    private final int _classId;
    private final int _dayOfWeek;
    private final List<DailyMission> _missions = new ArrayList<DailyMission>();

    public ExOneDayReceiveRewardList(Player player) {
        this._dayRemainTime = (int)((DAILY_REUSE_PATTERN.next(System.currentTimeMillis()) - System.currentTimeMillis()) / 1000L);
        this._weekRemainTime = (int)((WEEKLY_REUSE_PATTERN.next(System.currentTimeMillis()) - System.currentTimeMillis()) / 1000L);
        this._monthRemainTime = (int)((MONTHLY_REUSE_PATTERN.next(System.currentTimeMillis()) - System.currentTimeMillis()) / 1000L);
        this._classId = player.getBaseClassId();
        this._dayOfWeek = Calendar.getInstance().get(7);
        for (DailyMissionTemplate missionTemplate : player.getDailyMissionList().getAvailableMissions()) {
            DailyMission mission = player.getDailyMissionList().get(missionTemplate);
            if (mission.isFinallyCompleted()) continue;
            this._missions.add(mission);
        }
        Collections.sort(this._missions);
    }

    public ExOneDayReceiveRewardList() {
        this._dayRemainTime = (int)((DAILY_REUSE_PATTERN.next(System.currentTimeMillis()) - System.currentTimeMillis()) / 1000L);
        this._weekRemainTime = (int)((WEEKLY_REUSE_PATTERN.next(System.currentTimeMillis()) - System.currentTimeMillis()) / 1000L);
        this._monthRemainTime = (int)((MONTHLY_REUSE_PATTERN.next(System.currentTimeMillis()) - System.currentTimeMillis()) / 1000L);
        this._classId = 0;
        this._dayOfWeek = Calendar.getInstance().get(7);
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._dayRemainTime);
        this.writeD(this._weekRemainTime);
        this.writeD(this._monthRemainTime);
        this.writeC(20);
        this.writeD(this._classId);
        this.writeD(this._dayOfWeek);
        this.writeD(this._missions.size());
        for (DailyMission mission : this._missions) {
            this.writeH(mission.getId());
            this.writeC(mission.getStatus().ordinal());
            this.writeC(1);
            this.writeD(mission.getCurrentProgress());
            this.writeD(mission.getRequiredProgress());
        }
    }
}

