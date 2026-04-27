/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.olympiad;

import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadDatabase;

public class ValidationTask
implements Runnable {
    @Override
    public void run() {
        Olympiad._period = 0;
        ++Olympiad._currentCycle;
        OlympiadDatabase.setNewOlympiadStartTime();
        Olympiad.init();
        OlympiadDatabase.save();
    }
}

