package l2s.gameserver.model.entity.olympiad;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.list.TIntList;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.model.entity.olympiad.BattleStatus;
import l2s.gameserver.model.entity.olympiad.CompType;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadGame;
import l2s.gameserver.model.entity.olympiad.OlympiadGameTask;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OlympiadManager
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(OlympiadManager.class);
    private Map<Integer, OlympiadGame> _olympiadInstances = new ConcurrentHashMap<Integer, OlympiadGame>();

    public void sleep(long time) {
        try {
            Thread.sleep(time);
        }
        catch (InterruptedException interruptedException) {
            // empty catch block
        }
    }

    @Override
    public void run() {
        if (Olympiad.isOlympiadEnd()) {
            return;
        }
        while (Olympiad.inCompPeriod()) {
            if (Olympiad.getParticipantsMap().isEmpty()) {
                this.sleep(60000L);
                continue;
            }
            while (Olympiad.inCompPeriod()) {
                if (Olympiad._nonClassBasedRegisters.size() >= Config.NONCLASS_GAME_MIN) {
                    this.prepareBattles(CompType.NON_CLASSED, Olympiad._nonClassBasedRegisters);
                }
                TIntObjectIterator<TIntList> iterator = Olympiad._classBasedRegisters.iterator();
                while (iterator.hasNext()) {
                    iterator.advance();
                    if (((TIntList)iterator.value()).size() < Config.CLASS_GAME_MIN) continue;
                    this.prepareBattles(CompType.CLASSED, (TIntList)iterator.value());
                }
                this.sleep(30000L);
            }
            this.sleep(30000L);
        }
        Olympiad._classBasedRegisters.clear();
        Olympiad._nonClassBasedRegisters.clear();
        Olympiad._playersHWID.clear();
        boolean allGamesTerminated = false;
        while (!allGamesTerminated) {
            this.sleep(30000L);
            if (this._olympiadInstances.isEmpty()) break;
            allGamesTerminated = true;
            for (OlympiadGame game : this._olympiadInstances.values()) {
                if (game.getTask() == null || game.getTask().isTerminated()) continue;
                allGamesTerminated = false;
            }
        }
        this._olympiadInstances.clear();
    }

    private void prepareBattles(CompType type, TIntList list) {
        for (int i = 0; i < Olympiad.STADIUMS.length; ++i) {
            try {
                if (!Olympiad.STADIUMS[i].isFreeToUse()) continue;
                if (list.size() < 2) break;
                int[] nextOpponents = this.nextOpponents(list, type);
                OlympiadGame game = new OlympiadGame(i, type, nextOpponents[0], nextOpponents[1]);
                game.sheduleTask(new OlympiadGameTask(game, BattleStatus.Begining, 0, 1L));
                this._olympiadInstances.put(i, game);
                Olympiad.STADIUMS[i].setStadiaBusy();
                continue;
            }
            catch (Exception e) {
                _log.error("", (Throwable)e);
            }
        }
    }

    public void freeOlympiadInstance(int index) {
        this._olympiadInstances.remove(index);
        Olympiad.STADIUMS[index].setStadiaFree();
    }

    public OlympiadGame getOlympiadInstance(int index) {
        return this._olympiadInstances.get(index);
    }

    public Map<Integer, OlympiadGame> getOlympiadGames() {
        return this._olympiadInstances;
    }

    private int[] nextOpponents(TIntList list, CompType type) {
        int[] opponents = new int[2];
        for (int i = 0; i < 2; ++i) {
            int nobleObjectId = Rnd.get((int[])list.toArray());
            list.remove(nobleObjectId);
            opponents[i] = nobleObjectId;
            this.removeOpponent(nobleObjectId);
        }
        return opponents;
    }

    private void removeOpponent(Integer noble) {
        Olympiad._classBasedRegisters.removeValue(noble);
        Olympiad._nonClassBasedRegisters.remove(noble.intValue());
        Olympiad._playersHWID.remove(noble);
    }
}

