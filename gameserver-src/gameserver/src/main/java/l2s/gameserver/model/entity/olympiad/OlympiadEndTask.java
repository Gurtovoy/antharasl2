/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.entity.olympiad;

import l2s.gameserver.Announcements;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.instancemanager.OlympiadHistoryManager;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadDatabase;
import l2s.gameserver.model.entity.olympiad.ValidationTask;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OlympiadEndTask
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(OlympiadEndTask.class);

    @Override
    public void run() {
        if (Olympiad._inCompPeriod) {
            Olympiad.startOlympiadEndTask(60000L);
            return;
        }
        Announcements.announceToAll(new SystemMessage(1640).addNumber(Olympiad._currentCycle));
        Olympiad._isOlympiadEnd = true;
        if (Olympiad._scheduledManagerTask != null) {
            Olympiad._scheduledManagerTask.cancel(false);
        }
        if (Olympiad._scheduledWeeklyTask != null) {
            Olympiad._scheduledWeeklyTask.cancel(false);
        }
        Olympiad.setValidationStartTime(Olympiad.getOlympiadPeriodEndTime());
        Olympiad._period = 1;
        Hero.getInstance().clearHeroes();
        OlympiadHistoryManager.getInstance().switchData();
        for (Player player : GameObjectsStorage.getPlayers(false, true)) {
            player.checkAndDeleteOlympiadItems();
        }
        Hero.getInstance().computeNewHeroes(OlympiadDatabase.computeHeroesToBe());
        OlympiadDatabase.cleanupParticipants();
        OlympiadDatabase.loadParticipantsRank();
        try {
            OlympiadDatabase.save();
        }
        catch (Exception e) {
            _log.error("Olympiad System: Failed to save Olympiad configuration!", (Throwable)e);
        }
        _log.info("Olympiad System: Starting Validation period. Time to end validation: " + Olympiad.getMillisToValidationEnd() / 60000L + " minutes");
        if (Olympiad._scheduledValdationTask != null) {
            Olympiad._scheduledValdationTask.cancel(false);
        }
        Olympiad._scheduledValdationTask = ThreadPoolManager.getInstance().schedule(new ValidationTask(), Olympiad.getMillisToValidationEnd());
    }
}

