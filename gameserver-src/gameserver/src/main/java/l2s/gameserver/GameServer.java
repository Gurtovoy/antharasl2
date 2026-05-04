package l2s.gameserver;

import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.awt.Toolkit;
import java.io.File;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.lang.StatsUtils;
import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.commons.net.HostInfo;
import l2s.commons.net.nio.impl.IClientFactory;
import l2s.commons.net.nio.impl.IMMOExecutor;
import l2s.commons.net.nio.impl.IPacketHandler;
import l2s.commons.net.nio.impl.SelectorStats;
import l2s.commons.net.nio.impl.SelectorThread;
import l2s.commons.versioning.Version;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.GameTimeController;
import l2s.gameserver.Shutdown;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.cache.ImagesCache;
import l2s.gameserver.config.FloodProtectorConfigs;
import l2s.gameserver.config.xml.ConfigParsers;
import l2s.gameserver.config.xml.holder.HostsConfigHolder;
import l2s.gameserver.config.xml.holder.VoteRewardConfigHolder;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.dao.CustomHeroDAO;
import l2s.gameserver.dao.FencesDAO;
import l2s.gameserver.dao.HidenItemsDAO;
import l2s.gameserver.dao.ItemsDAO;
import l2s.gameserver.data.BoatHolder;
import l2s.gameserver.data.xml.Parsers;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.data.xml.holder.StaticObjectHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.database.UpdatesInstaller;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.handler.admincommands.AdminCommandHandler;
import l2s.gameserver.handler.bbs.BbsHandlerHolder;
import l2s.gameserver.handler.bypass.BypassHolder;
import l2s.gameserver.handler.dailymissions.DailyMissionHandlerHolder;
import l2s.gameserver.handler.items.ItemHandler;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.handler.usercommands.UserCommandHandler;
import l2s.gameserver.handler.voicecommands.VoicedCommandHandler;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.instancemanager.AutobotsManager;
import l2s.gameserver.instancemanager.AutobotScheduler;
import l2s.gameserver.instancemanager.BotCheckManager;
import l2s.gameserver.instancemanager.BotReportManager;
import l2s.gameserver.instancemanager.CoupleManager;
import l2s.gameserver.instancemanager.GameBanManager;
import l2s.gameserver.instancemanager.PetitionManager;
import l2s.gameserver.instancemanager.PlayerMessageStack;
import l2s.gameserver.instancemanager.RaidBossSpawnManager;
import l2s.gameserver.instancemanager.SpawnManager;
import l2s.gameserver.instancemanager.StarterPackManager;
import l2s.gameserver.instancemanager.TrainingCampManager;
import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.instancemanager.games.MiniGameScoreManager;
import l2s.gameserver.listener.GameListener;
import l2s.gameserver.listener.game.OnShutdownListener;
import l2s.gameserver.listener.game.OnStartListener;
import l2s.gameserver.model.World;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.MonsterRace;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.GamePacketHandler;
import l2s.gameserver.network.telnet.TelnetServer;
import l2s.gameserver.network.webserver.WebServer;
import l2s.gameserver.scripts.Scripts;
import l2s.gameserver.security.HWIDBan;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.tables.EnchantHPBonusTable;
import l2s.gameserver.tables.FakePlayersTable;
import l2s.gameserver.tables.SubClassTable;
import l2s.gameserver.taskmanager.AutomaticTasks;
import l2s.gameserver.taskmanager.ItemsAutoDestroy;
import l2s.gameserver.utils.OnlineTxtGenerator;
import l2s.gameserver.utils.Strings;
import l2s.gameserver.utils.TradeHelper;
import l2s.gameserver.utils.velocity.VelocityUtils;
import net.sf.ehcache.CacheManager;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameServer {
    public static boolean DEVELOP = false;
    public static final String PROJECT_REVISION = "L2s [31495]";
    public static final String UPDATE_NAME = "Classic: Saviors (Antharas)";
    public static final int AUTH_SERVER_PROTOCOL = 4;
    private static final Logger _log = LoggerFactory.getLogger(GameServer.class);
    public static GameServer _instance;
    private final List<SelectorThread<GameClient>> _selectorThreads = new ArrayList<SelectorThread<GameClient>>();
    private final SelectorStats _selectorStats = new SelectorStats();
    private Version version;
    private TelnetServer statusServer;
    private final GameServerListenerList _listeners;
    private long _serverStartTimeMillis;
    private final String _licenseHost;
    private final int _onlineLimit;

    public List<SelectorThread<GameClient>> getSelectorThreads() {
        return this._selectorThreads;
    }

    public SelectorStats getSelectorStats() {
        return this._selectorStats;
    }

    public long getServerStartTime() {
        return this._serverStartTimeMillis;
    }

    public String getLicenseHost() {
        return this._licenseHost;
    }

    public int getOnlineLimit() {
        return this._onlineLimit;
    }

    public GameServer() throws Exception {
        int count;
        _instance = this;
        this._serverStartTimeMillis = System.currentTimeMillis();
        this._listeners = new GameServerListenerList();
        new File("./log/").mkdir();
        this.version = new Version(GameServer.class);
        _log.info("=================================================");
        _log.info("Project Revision: ........ L2s [31495]");
        _log.info("Build Revision: .......... " + this.version.getRevisionNumber());
        _log.info("Update: .................. Classic: Saviors (Antharas)");
        _log.info("Build date: .............. " + this.version.getBuildDate());
        _log.info("Compiler version: ........ " + this.version.getBuildJdk());
        _log.info("=================================================");
        ConfigParsers.parseAllOnLoad();
        Config.load();
        FloodProtectorConfigs.load();
        VelocityUtils.init();
        HostInfo[] hosts = HostsConfigHolder.getInstance().getGameServerHosts();
        if (hosts.length == 0) {
            throw new Exception("Server hosts list is empty!");
        }
        TIntHashSet ports = new TIntHashSet();
        for (HostInfo host : hosts) {
            if (host.getAddress() == null) continue;
            ports.add(host.getPort());
        }
        if (ports.isEmpty()) {
            throw new Exception("Server ports list is empty!");
        }
        this.checkFreePorts((TIntSet)ports);
        int[] portsArray = ports.toArray();
        String licenseHost = "";
        boolean onlineLimit = false;
        this._licenseHost = Config.EXTERNAL_HOSTNAME;
        this._onlineLimit = Config.MAXIMUM_ONLINE_USERS;
        if (this._onlineLimit == 0) {
            throw new Exception("Server online limit is zero!");
        }
        Class.forName(Config.DATABASE_DRIVER).newInstance();
        DatabaseFactory.getInstance().getConnection().close();
        UpdatesInstaller.checkAndInstall();
        IdFactory _idFactory = IdFactory.getInstance();
        if (!_idFactory.isInitialized()) {
            _log.error("Could not read object IDs from DB. Please Check Your Data.");
            throw new Exception("Could not initialize the ID factory");
        }
        CacheManager.getInstance();
        ThreadPoolManager.getInstance();
        BotCheckManager.loadBotQuestions();
        HidenItemsDAO.LoadAllHiddenItems();
        CustomHeroDAO.getInstance();
        HWIDBan.getInstance().load();
        ItemHandler.getInstance();
        DailyMissionHandlerHolder.getInstance();
        Scripts.getInstance();
        GeoEngine.load();
        Strings.reload();
        GameTimeController.getInstance();
        World.init();
        Parsers.parseAll();
        ItemsDAO.getInstance();
        ThreadPoolManager.getInstance().execute(() -> {
            CrestCache.getInstance();
            ImagesCache.getInstance();
        });
        CharacterDAO.getInstance();
        ClanTable.getInstance();
        SubClassTable.getInstance();
        EnchantHPBonusTable.getInstance();
        FencesDAO.getInstance().restore();
        StaticObjectHolder.getInstance().spawnAll();
        SpawnManager.getInstance().spawnAll();
        RaidBossSpawnManager.getInstance();
        ConfigParsers.parseAllOnInit();
        Scripts.getInstance().init();
        Announcements.getInstance();
        PlayerMessageStack.getInstance();
        ThreadPoolManager.getInstance().scheduleAtFixedDelay(() -> PlayerMessageStack.getInstance().cleanup(), 3600000L, 3600000L);
        if (Config.AUTODESTROY_ITEM_AFTER > 0) {
            ItemsAutoDestroy.getInstance();
        }
        MonsterRace.getInstance();
        if (Config.ENABLE_OLYMPIAD) {
            Olympiad.load();
            Hero.getInstance();
        }
        PetitionManager.getInstance();
        if (Config.ALLOW_WEDDING) {
            CoupleManager.getInstance();
        }
        AdminCommandHandler.getInstance().log();
        UserCommandHandler.getInstance().log();
        VoicedCommandHandler.getInstance().log();
        BbsHandlerHolder.getInstance().log();
        BypassHolder.getInstance().log();
        OnShiftActionHolder.getInstance().log();
        AutomaticTasks.init();
        ClanTable.getInstance().checkClans();
        _log.info("=[Events]=========================================");
        ResidenceHolder.getInstance().callInit();
        EventHolder.getInstance().callInit();
        _log.info("==================================================");
        BoatHolder.getInstance().spawnAll();
        Runtime.getRuntime().addShutdownHook(Shutdown.getInstance());
        _log.info("IdFactory: Free ObjectID's remaining: " + IdFactory.getInstance().size());
        MiniGameScoreManager.getInstance();
        ClanSearchManager.getInstance().load();
        BotReportManager.getInstance();
        TrainingCampManager.getInstance().init();
        VoteRewardConfigHolder.getInstance().callInit();
        Shutdown.getInstance().schedule(Config.RESTART_AT_TIME, 2);
        _log.info("GameServer Started");
        _log.info("Maximum Numbers of Connected Players: " + this.getOnlineLimit());
        GameBanManager.getInstance().init();
        this.registerSelectorThreads((TIntSet)ports);
        this.getListeners().onStart();
        if (Config.BUFF_STORE_ENABLED) {
            _log.info("Restoring offline buffers...");
            count = TradeHelper.restoreOfflineBuffers();
            _log.info("Restored " + count + " offline buffers.");
        }
        if (Config.SERVICES_OFFLINE_TRADE_RESTORE_AFTER_RESTART) {
            _log.info("Restoring offline traders...");
            count = TradeHelper.restoreOfflineTraders();
            _log.info("Restored " + count + " offline traders.");
        }
        if (Config.ONLINE_GENERATOR_ENABLED) {
            ThreadPoolManager.getInstance().scheduleAtFixedRate(new OnlineTxtGenerator(), 5000L, (long)(Config.ONLINE_GENERATOR_DELAY * 60) * 1000L);
        }
        AuthServerCommunication.getInstance().start();
        Toolkit.getDefaultToolkit().beep();
        if (Config.IS_TELNET_ENABLED) {
            this.statusServer = new TelnetServer();
        } else {
            _log.info("Telnet server is currently disabled.");
        }
        _log.info("=================================================");
        String memUsage = "" + StatsUtils.getMemUsage();
        for (String line : memUsage.split("\n")) {
            _log.info(line);
        }
        _log.info("=================================================");
        FakePlayersTable.getInstance();
        AutobotsManager.getInstance().init();
        AutobotScheduler.getInstance().init();
        StarterPackManager.getInstance().init();
        if(Config.WEB_SERVER_ENABLED)
        {
            WebServer.getInstance().init();
        }
    }

    public GameServerListenerList getListeners() {
        return this._listeners;
    }

    public static GameServer getInstance() {
        return _instance;
    }

    public <T extends GameListener> boolean addListener(T listener) {
        return this._listeners.add(listener);
    }

    public <T extends GameListener> boolean removeListener(T listener) {
        return this._listeners.remove(listener);
    }

    private void checkFreePorts(TIntSet ports) {
        for (int port : ports.toArray()) {
            while (!GameServer.checkFreePort(null, port)) {
                _log.warn("Port '" + port + "' is allready binded. Please free it and restart server.");
                try {
                    Thread.sleep(1000L);
                }
                catch (InterruptedException e2) {}
            }
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static boolean checkFreePort(String hostname, int port) {
        ServerSocket ss = null;
        try {
            ss = StringUtils.isEmpty((CharSequence)hostname) || hostname.equalsIgnoreCase("*") || hostname.equalsIgnoreCase("0.0.0.0") ? new ServerSocket(port) : new ServerSocket(port, 50, InetAddress.getByName(hostname));
        }
        catch (Exception e) {
            boolean bl = false;
            return bl;
        }
        finally {
            try {
                ss.close();
            }
            catch (Exception e) {}
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static boolean checkOpenPort(String ip, int port) {
        Socket socket = null;
        try {
            socket = new Socket();
            socket.connect(new InetSocketAddress(ip, port), 100);
        }
        catch (Exception e) {
            boolean bl = false;
            return bl;
        }
        finally {
            try {
                socket.close();
            }
            catch (Exception e) {}
        }
        return true;
    }

    private void registerSelectorThreads(TIntSet ports) {
        GamePacketHandler gph = new GamePacketHandler();
        for (int port : ports.toArray()) {
            this.registerSelectorThread(gph, null, port);
        }
    }

    private void registerSelectorThread(GamePacketHandler gph, String ip, int port) {
        try {
            SelectorThread selectorThread = new SelectorThread(Config.SELECTOR_CONFIG, this._selectorStats, (IPacketHandler)gph, (IMMOExecutor)gph, (IClientFactory)gph, null);
            selectorThread.openServerSocket(ip == null ? null : InetAddress.getByName(ip), port);
            selectorThread.start();
            this._selectorThreads.add((SelectorThread<GameClient>)selectorThread);
        }
        catch (Exception e) {
            // empty catch block
        }
    }

    public static void main(String[] args) throws Exception {
        for (String arg : args) {
            if (!arg.equalsIgnoreCase("-dev")) continue;
            DEVELOP = true;
        }
        new GameServer();
    }

    public Version getVersion() {
        return this.version;
    }

    public TelnetServer getStatusServer() {
        return this.statusServer;
    }

    public class GameServerListenerList
    extends ListenerList<GameServer> {
        public void onStart() {
            for (Listener listener : this.getListeners()) {
                if (!OnStartListener.class.isInstance(listener)) continue;
                ((OnStartListener)listener).onStart();
            }
        }

        public void onShutdown() {
            for (Listener listener : this.getListeners()) {
                if (!OnShutdownListener.class.isInstance(listener)) continue;
                ((OnShutdownListener)listener).onShutdown();
            }
        }
    }
}

