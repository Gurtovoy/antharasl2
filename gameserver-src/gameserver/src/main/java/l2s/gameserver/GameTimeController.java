/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.listener.Listener
 *  l2s.commons.listener.ListenerList
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver;

import java.util.Calendar;
import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.gameserver.GameServer;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.listener.GameListener;
import l2s.gameserver.listener.game.OnDayNightChangeListener;
import l2s.gameserver.listener.game.OnGameHourChangeListener;
import l2s.gameserver.listener.game.OnStartListener;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ClientSetTimePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameTimeController {
    private static final Logger _log = LoggerFactory.getLogger(GameTimeController.class);
    public static final int TICKS_PER_SECOND = 10;
    public static final int MILLIS_IN_TICK = 100;
    public static final int NIGHT_START_HOUR = 0;
    public static final int DAY_START_HOUR = 6;
    private static final GameTimeController _instance = new GameTimeController();
    private long _gameStartTime;
    private GameTimeListenerList listenerEngine = new GameTimeListenerList();

    public static final GameTimeController getInstance() {
        return _instance;
    }

    private GameTimeController() {
        this._gameStartTime = GameTimeController.generateDayStartTime();
        GameServer.getInstance().addListener(new OnStartListenerImpl());
        StringBuilder msg = new StringBuilder();
        msg.append("GameTimeController: initialized.").append(" ");
        msg.append("Current time is ");
        msg.append(this.getGameHour()).append(":");
        if (this.getGameMin() < 10) {
            msg.append("0");
        }
        msg.append(this.getGameMin());
        msg.append(" in the ");
        if (this.isNowNight()) {
            msg.append("night");
        } else {
            msg.append("day");
        }
        msg.append(".");
        _log.info(msg.toString());
        long oneGameHourInMillis = 600000L;
        long hourStart = 0L;
        while (this._gameStartTime + hourStart < System.currentTimeMillis()) {
            hourStart += 600000L;
        }
        GameHourlyTask gameHourlyTask = new GameHourlyTask(false);
        ThreadPoolManager.getInstance().scheduleAtFixedRate(gameHourlyTask, hourStart -= System.currentTimeMillis() - this._gameStartTime, 600000L);
    }

    private static long generateDayStartTime() {
        Calendar dayStart = Calendar.getInstance();
        int HOUR_OF_DAY = dayStart.get(11);
        dayStart.add(11, -(HOUR_OF_DAY + 1) % 4);
        dayStart.set(12, 0);
        dayStart.set(13, 0);
        dayStart.set(14, 0);
        return dayStart.getTimeInMillis();
    }

    public long getDayStartTime() {
        return this._gameStartTime;
    }

    public static boolean isNowNight(int hour) {
        return hour >= 0 && hour < 6;
    }

    public boolean isNowNight() {
        return GameTimeController.isNowNight(this.getGameHour());
    }

    public int getGameTime() {
        return this.getGameTicks() / 100;
    }

    public int getGameHour() {
        return this.getGameTime() / 60 % 24;
    }

    public int getGameMin() {
        return this.getGameTime() % 60;
    }

    public int getGameTicks() {
        return (int)((System.currentTimeMillis() - this._gameStartTime) / 100L);
    }

    public GameTimeListenerList getListenerEngine() {
        return this.listenerEngine;
    }

    public <T extends GameListener> boolean addListener(T listener) {
        return this.listenerEngine.add(listener);
    }

    public <T extends GameListener> boolean removeListener(T listener) {
        return this.listenerEngine.remove(listener);
    }

    private class GameTimeListenerList
    extends ListenerList<GameServer> {
        private GameTimeListenerList() {
        }

        public void onChangeHour(int hour, boolean onStart) {
            for (Listener listener : this.getListeners()) {
                if (!OnGameHourChangeListener.class.isInstance(listener)) continue;
                ((OnGameHourChangeListener)listener).onChangeHour(hour, onStart);
            }
        }

        public void onDay(boolean onStart) {
            for (Listener listener : this.getListeners()) {
                if (!OnDayNightChangeListener.class.isInstance(listener)) continue;
                ((OnDayNightChangeListener)listener).onDay(onStart);
            }
        }

        public void onNight(boolean onStart) {
            for (Listener listener : this.getListeners()) {
                if (!OnDayNightChangeListener.class.isInstance(listener)) continue;
                ((OnDayNightChangeListener)listener).onNight(onStart);
            }
        }
    }

    private class GameHourlyTask
    implements Runnable {
        private final boolean _onStart;

        public GameHourlyTask(boolean onStart) {
            this._onStart = onStart;
        }

        @Override
        public void run() {
            int hour = GameTimeController.this.getGameHour();
            GameTimeController.getInstance().getListenerEngine().onChangeHour(hour, this._onStart);
            boolean dayTimeChanged = false;
            if (this._onStart) {
                if (GameTimeController.isNowNight(hour)) {
                    GameTimeController.getInstance().getListenerEngine().onNight(this._onStart);
                } else {
                    GameTimeController.getInstance().getListenerEngine().onDay(this._onStart);
                }
                dayTimeChanged = true;
            } else if (hour == 0) {
                GameTimeController.getInstance().getListenerEngine().onNight(this._onStart);
                dayTimeChanged = true;
            } else if (hour == 6) {
                GameTimeController.getInstance().getListenerEngine().onDay(this._onStart);
                dayTimeChanged = true;
            }
            if (dayTimeChanged) {
                ClientSetTimePacket packet = new ClientSetTimePacket();
                for (Player player : GameObjectsStorage.getPlayers(false, false)) {
                    player.checkDayNightMessages();
                    player.sendPacket((IBroadcastPacket)packet);
                }
            }
        }
    }

    private class OnStartListenerImpl
    implements OnStartListener {
        private OnStartListenerImpl() {
        }

        @Override
        public void onStart() {
            ThreadPoolManager.getInstance().execute(new GameHourlyTask(true));
        }
    }
}

