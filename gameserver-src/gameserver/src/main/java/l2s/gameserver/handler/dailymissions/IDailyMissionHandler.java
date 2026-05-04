/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.dailymissions;

import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.listener.CharListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.DailyMission;
import l2s.gameserver.templates.dailymissions.DailyMissionStatus;

public interface IDailyMissionHandler {
    public CharListener getListener();

    public DailyMissionStatus getStatus(Player var1, DailyMission var2);

    public int getProgress(Player var1, DailyMission var2);

    public boolean isReusable();

    public SchedulingPattern getReusePattern();
}

