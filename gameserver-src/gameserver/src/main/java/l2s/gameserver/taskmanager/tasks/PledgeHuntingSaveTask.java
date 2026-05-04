package l2s.gameserver.taskmanager.tasks;

import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.taskmanager.tasks.AutomaticTask;

public class PledgeHuntingSaveTask
extends AutomaticTask {
    private static final long SAVE_DELAY = 600000L;

    @Override
    public void doTask() throws Exception {
        ClanTable.getInstance().saveClanHuntingProgress();
    }

    @Override
    public long reCalcTime(boolean start) {
        return System.currentTimeMillis() + 600000L;
    }
}

