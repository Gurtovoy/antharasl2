package l2s.gameserver;

import java.util.Timer;
import java.util.TimerTask;
import l2s.commons.net.nio.impl.SelectorThread;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.GameServer;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.instancemanager.AutobotsManager;
import l2s.gameserver.instancemanager.AutobotScheduler;
import l2s.gameserver.instancemanager.BotReportManager;
import l2s.gameserver.instancemanager.CoupleManager;
import l2s.gameserver.instancemanager.RaidBossSpawnManager;
import l2s.gameserver.instancemanager.StarterPackManager;
import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.network.webserver.WebServer;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.olympiad.OlympiadDatabase;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.utils.Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Shutdown
extends Thread {
    private static final Logger _log = LoggerFactory.getLogger(Shutdown.class);
    public static final int SHUTDOWN = 0;
    public static final int RESTART = 2;
    public static final int NONE = -1;
    public static final int FULL_ANNOUNCES = 2;
    public static final int OFFLIKE_ANNOUNCES = 1;
    private static final Shutdown _instance = new Shutdown();
    private Timer counter;
    private int shutdownMode;
    private int shutdownCounter;

    public static final Shutdown getInstance() {
        return _instance;
    }

    private Shutdown() {
        this.setName(this.getClass().getSimpleName());
        this.setDaemon(true);
        this.shutdownMode = -1;
    }

    public int getSeconds() {
        return this.shutdownMode == -1 ? -1 : this.shutdownCounter;
    }

    public int getMode() {
        return this.shutdownMode;
    }

    public synchronized void schedule(int seconds, int shutdownMode) {
        if (seconds < 0) {
            return;
        }
        if (this.counter != null) {
            this.counter.cancel();
        }
        this.shutdownMode = shutdownMode;
        this.shutdownCounter = seconds;
        _log.info("Scheduled server " + (shutdownMode == 0 ? "shutdown" : "restart") + " in " + Util.formatTime(seconds) + ".");
        this.counter = new Timer("ShutdownCounter", true);
        this.counter.scheduleAtFixedRate((TimerTask)new ShutdownCounter(), 0L, 1000L);
    }

    public void schedule(String time, int shutdownMode) {
        SchedulingPattern cronTime;
        try {
            cronTime = new SchedulingPattern(time);
        }
        catch (SchedulingPattern.InvalidPatternException e) {
            return;
        }
        int seconds = (int)(cronTime.next(System.currentTimeMillis()) / 1000L - System.currentTimeMillis() / 1000L);
        this.schedule(seconds, shutdownMode);
    }

    public synchronized void cancel() {
        this.shutdownMode = -1;
        if (this.counter != null) {
            this.counter.cancel();
        }
        this.counter = null;
    }

    @Override
    public void run() {
        _log.info("Shutting down LS/GS communication...");
        AuthServerCommunication.getInstance().shutdown();
        _log.info("Disconnecting players...");
        this.disconnectAllPlayers();
        GameServer gameServer = GameServer.getInstance();
        if (gameServer != null) {
            gameServer.getListeners().onShutdown();
        }
        _log.info("Saving data...");
        this.saveData();
        try {
            _log.info("Shutting down thread pool...");
            ThreadPoolManager.getInstance().shutdown();
        }
        catch (Exception e) {
            _log.error("Thread pool shutdown failed", e);
        }
        _log.info("Shutting down selector...");
        if (gameServer != null) {
            for (SelectorThread<GameClient> st : gameServer.getSelectorThreads()) {
                try {
                    st.shutdown();
                }
                catch (Exception e) {
                    _log.error("Selector shutdown failed: " + st, e);
                }
            }
        }
        try {
            _log.info("Shutting down database communication...");
            DatabaseFactory.getInstance().shutdown();
        }
        catch (Exception e) {
            _log.error("Database shutdown failed", e);
        }
        _log.info("Shutdown finished.");
    }

    private void saveData() {
        try {
            AutobotScheduler.getInstance().shutdown();
            _log.info("AutobotScheduler: Shutdown complete.");
        }
        catch (Exception e) {
            _log.error("AutobotScheduler shutdown failed", e);
        }
        try {
            AutobotsManager.getInstance().shutdown();
            _log.info("AutobotsManager: All bots despawned.");
        }
        catch (Exception e) {
            _log.error("AutobotsManager shutdown failed", e);
        }
        try {
            StarterPackManager.getInstance().shutdown();
            _log.info("StarterPackManager: All starter bots despawned.");
        }
        catch (Exception e) {
            _log.error("StarterPackManager shutdown failed", e);
        }
        try {
            WebServer.getInstance().shutdown();
            _log.info("WebServer: Stopped.");
        }
        catch (Exception e) {
            _log.error("WebServer shutdown failed", e);
        }
        try {
            RaidBossSpawnManager.getInstance().updateAllStatusDb();
            _log.info("RaidBossSpawnManager: Data saved.");
        }
        catch (Exception e) {
            _log.error("RaidBossSpawnManager save failed", e);
        }
        if (Config.ENABLE_OLYMPIAD) {
            try {
                OlympiadDatabase.save();
                _log.info("Olympiad: Data saved.");
            }
            catch (Exception e) {
                _log.error("Olympiad save failed", e);
            }
        }
        if (Config.ALLOW_WEDDING) {
            try {
                CoupleManager.getInstance().store();
                _log.info("CoupleManager: Data saved.");
            }
            catch (Exception e) {
                _log.error("CoupleManager save failed", e);
            }
        }
        try {
            Hero.getInstance().shutdown();
            _log.info("Hero: Data saved.");
        }
        catch (Exception e) {
            _log.error("Hero shutdown failed", e);
        }
        try {
            ClanTable.getInstance().storeClanWars();
            _log.info("Clan War: Data saved.");
        }
        catch (Exception e) {
            _log.error("Clan war save failed", e);
        }
        try {
            ClanTable.getInstance().saveClanHuntingProgress();
            _log.info("Clan Data: Hunting progress saved.");
        }
        catch (Exception e) {
            _log.error("Clan hunting progress save failed", e);
        }
        try {
            ClanSearchManager.getInstance().save();
            _log.info("ClanSearchManager: Data saved.");
        }
        catch (Exception e) {
            _log.error("ClanSearchManager save failed", e);
        }
        if (Config.BOTREPORT_ENABLED) {
            try {
                BotReportManager.getInstance().saveReportedCharData();
                _log.info("BotReportManager: Data saved.");
            }
            catch (Exception e) {
                _log.error("BotReportManager save failed", e);
            }
        }
    }

    private void disconnectAllPlayers() {
        for (Player player : GameObjectsStorage.getPlayers(true, true)) {
            try {
                player.logout();
            }
            catch (Exception e) {
                _log.error("Error while disconnecting player: {}", player, e);
            }
        }
        _log.info("All players disconnected.");
    }

    private class ShutdownCounter
    extends TimerTask {
        private ShutdownCounter() {
        }

        @Override
        public void run() {
            switch (Shutdown.this.shutdownCounter) {
                case 60: 
                case 120: 
                case 180: 
                case 240: 
                case 300: 
                case 600: 
                case 900: 
                case 1800: {
                    if (Config.SHUTDOWN_ANN_TYPE != 2) break;
                    Announcements.announceToAllFromStringHolder("THE_SERVER_WILL_BE_COMING_DOWN_IN_S1_MINUTES", String.valueOf(Shutdown.this.shutdownCounter / 60));
                    break;
                }
                case 5: 
                case 10: 
                case 20: 
                case 30: {
                    if (Config.SHUTDOWN_ANN_TYPE != 2 && Config.SHUTDOWN_ANN_TYPE != 1) break;
                    Announcements.announceToAll(new SystemMessagePacket(SystemMsg.THE_SERVER_WILL_BE_COMING_DOWN_IN_S1_SECONDS__PLEASE_FIND_A_SAFE_PLACE_TO_LOG_OUT).addInteger(Shutdown.this.shutdownCounter));
                    break;
                }
                case 0: {
                    switch (Shutdown.this.shutdownMode) {
                        case 0: {
                            Runtime.getRuntime().exit(0);
                            break;
                        }
                        case 2: {
                            Runtime.getRuntime().exit(2);
                        }
                    }
                    this.cancel();
                    return;
                }
            }
            Shutdown.this.shutdownCounter--;
        }
    }
}

