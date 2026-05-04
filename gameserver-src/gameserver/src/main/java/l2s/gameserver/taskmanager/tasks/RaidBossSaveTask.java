/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.taskmanager.tasks;

import l2s.gameserver.instancemanager.RaidBossSpawnManager;
import l2s.gameserver.taskmanager.tasks.AutomaticTask;

public class RaidBossSaveTask
extends AutomaticTask {
    @Override
    public void doTask() throws Exception {
        RaidBossSpawnManager.getInstance().updateAllStatusDb();
    }

    @Override
    public long reCalcTime(boolean start) {
        return System.currentTimeMillis() + 60000L;
    }
}

