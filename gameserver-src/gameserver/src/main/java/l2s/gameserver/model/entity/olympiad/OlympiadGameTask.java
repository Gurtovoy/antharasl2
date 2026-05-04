/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.olympiad;

import java.util.concurrent.ScheduledFuture;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.entity.olympiad.BattleStatus;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadGame;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.utils.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OlympiadGameTask
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(OlympiadGameTask.class);
    private OlympiadGame _game;
    private BattleStatus _status;
    private int _count;
    private long _time;
    private boolean _terminated = false;

    public boolean isTerminated() {
        return this._terminated;
    }

    public BattleStatus getStatus() {
        return this._status;
    }

    public int getCount() {
        return this._count;
    }

    public OlympiadGame getGame() {
        return this._game;
    }

    public long getTime() {
        return this._count;
    }

    public ScheduledFuture<?> shedule() {
        return ThreadPoolManager.getInstance().schedule(this, this._time);
    }

    public OlympiadGameTask(OlympiadGame game, BattleStatus status, int count, long time) {
        this._game = game;
        this._status = status;
        this._count = count;
        this._time = time;
    }

    @Override
    public void run() {
        if (this._game == null || this._terminated) {
            return;
        }
        OlympiadGameTask task = null;
        int gameId = this._game.getId();
        try {
            if (!Olympiad.inCompPeriod()) {
                return;
            }
            if (!this._game.checkPlayersOnline() && this._status != BattleStatus.ValidateWinner && this._status != BattleStatus.Ending) {
                Log.add("Player is offline for game " + gameId + ", status: " + (Object)((Object)this._status), "olympiad");
                this._game.endGame(1000L, true);
                return;
            }
            switch (this._status) {
                case Begining: {
                    int delay = Config.OLYMPIAD_BEGINIG_DELAY;
                    if (delay <= 0) {
                        task = new OlympiadGameTask(this._game, BattleStatus.PortPlayers, 0, 1000L);
                        break;
                    }
                    this._game.broadcastPacket(new SystemMessage(1492).addNumber(delay), true, false);
                    if (delay > 60) {
                        int time = delay % 60;
                        if (time == 0) {
                            time = 60;
                        }
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, delay - time, time * 1000);
                        break;
                    }
                    if (delay <= 60 && delay > 30) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, 30, (delay - 30) * 1000);
                        break;
                    }
                    if (delay <= 30 && delay > 15) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, 15, (delay - 15) * 1000);
                        break;
                    }
                    if (delay <= 15 && delay > 5) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, 5, (delay - 5) * 1000);
                        break;
                    }
                    if (delay > 5 || delay <= 0) break;
                    task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, delay, 1000L);
                    break;
                }
                case Begin_Countdown: {
                    this._game.broadcastPacket(new SystemMessage(1492).addNumber(this._count), true, false);
                    if (this._count > 60 && this._count % 60 == 0) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, this._count - 60, 60000L);
                        break;
                    }
                    if (this._count == 60) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, 30, 30000L);
                        break;
                    }
                    if (this._count == 30) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, 15, 15000L);
                        break;
                    }
                    if (this._count == 15) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, 5, 10000L);
                        break;
                    }
                    if (this._count < 6 && this._count > 1) {
                        task = new OlympiadGameTask(this._game, BattleStatus.Begin_Countdown, this._count - 1, 1000L);
                        break;
                    }
                    if (this._count != 1) break;
                    task = new OlympiadGameTask(this._game, BattleStatus.PortPlayers, 0, 1000L);
                    break;
                }
                case PortPlayers: {
                    if (!this._game.validatePlayers()) {
                        Log.add("Player is dont valid for game " + gameId + ", status: " + (Object)((Object)this._status), "olympiad");
                        this._game.endGame(1000L, true);
                        return;
                    }
                    this._game.portPlayersToArena();
                    this._game.managerShout();
                    task = new OlympiadGameTask(this._game, BattleStatus.Started, 60, 1000L);
                    break;
                }
                case Started: {
                    if (this._count == 60) {
                        this._game.setState(1);
                        this._game.preparePlayers1();
                        this._game.addBuffers();
                    } else if (this._count == 55) {
                        this._game.preparePlayers2();
                        task = new OlympiadGameTask(this._game, BattleStatus.Started, 50, 5000L);
                        break;
                    }
                    this._game.broadcastPacket(new SystemMessage(1495).addNumber(this._count), true, true);
                    this._count -= 10;
                    if (this._count > 0) {
                        if (this._count == 60) {
                            task = new OlympiadGameTask(this._game, BattleStatus.Started, 55, 5000L);
                            break;
                        }
                        task = new OlympiadGameTask(this._game, BattleStatus.Started, this._count, 10000L);
                        break;
                    }
                    this._game.openDoors();
                    task = new OlympiadGameTask(this._game, BattleStatus.CountDown, 5, 5000L);
                    break;
                }
                case CountDown: {
                    this._game.broadcastPacket(new SystemMessage(1495).addNumber(this._count), true, true);
                    --this._count;
                    if (this._count <= 0) {
                        task = new OlympiadGameTask(this._game, BattleStatus.StartComp, 36, 1000L);
                        break;
                    }
                    task = new OlympiadGameTask(this._game, BattleStatus.CountDown, this._count, 1000L);
                    break;
                }
                case StartComp: {
                    if (this._count == 36) {
                        this._game.deleteBuffers();
                        this._game.setState(2);
                        this._game.broadcastPacket(SystemMsg.THE_MATCH_HAS_STARTED, true, true);
                        this._game.broadcastInfo(null, null, false);
                    }
                    --this._count;
                    if (this._count == 0) {
                        task = new OlympiadGameTask(this._game, BattleStatus.ValidateWinner, 0, 10000L);
                        break;
                    }
                    task = new OlympiadGameTask(this._game, BattleStatus.StartComp, this._count, 10000L);
                    break;
                }
                case ValidateWinner: {
                    try {
                        this._game.validateWinner(this._count > 0);
                    }
                    catch (Exception e) {
                        _log.error("", (Throwable)e);
                    }
                    task = new OlympiadGameTask(this._game, BattleStatus.Ending, 0, 20000L);
                    break;
                }
                case Ending: {
                    this._game.collapse();
                    this._terminated = true;
                    if (Olympiad._manager != null) {
                        Olympiad._manager.freeOlympiadInstance(this._game.getId());
                    }
                    return;
                }
            }
            if (task == null) {
                Log.add("task == null for game " + gameId, "olympiad");
                Thread.dumpStack();
                this._game.endGame(1000L, true);
                return;
            }
            this._game.sheduleTask(task);
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
            this._game.endGame(1000L, true);
        }
    }
}

