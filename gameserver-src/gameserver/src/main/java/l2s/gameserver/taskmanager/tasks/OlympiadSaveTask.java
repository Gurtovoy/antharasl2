/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.taskmanager.tasks;

import l2s.gameserver.model.entity.olympiad.OlympiadDatabase;
import l2s.gameserver.taskmanager.tasks.AutomaticTask;

public class OlympiadSaveTask
extends AutomaticTask {
    @Override
    public void doTask() throws Exception {
        OlympiadDatabase.save();
    }

    @Override
    public long reCalcTime(boolean start) {
        return System.currentTimeMillis() + 600000L;
    }
}

