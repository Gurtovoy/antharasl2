/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.net.nio.impl.IAcceptFilter
 *  l2s.commons.net.nio.impl.IClientFactory
 *  l2s.commons.net.nio.impl.IMMOExecutor
 *  l2s.commons.net.nio.impl.IPacketHandler
 *  l2s.commons.net.nio.impl.SelectorConfig
 *  l2s.commons.net.nio.impl.SelectorStats
 *  l2s.commons.net.nio.impl.SelectorThread
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver;

import java.io.File;
import java.io.IOException;
import java.net.InetAddress;
import java.net.ServerSocket;
import l2s.authserver.AuthBanManager;
import l2s.authserver.Config;
import l2s.authserver.GameServerManager;
import l2s.authserver.database.DatabaseFactory;
import l2s.authserver.network.gamecomm.GameServerCommunication;
import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.L2LoginPacketHandler;
import l2s.authserver.network.l2.SelectorHelper;
import l2s.commons.net.nio.impl.IAcceptFilter;
import l2s.commons.net.nio.impl.IClientFactory;
import l2s.commons.net.nio.impl.IMMOExecutor;
import l2s.commons.net.nio.impl.IPacketHandler;
import l2s.commons.net.nio.impl.SelectorConfig;
import l2s.commons.net.nio.impl.SelectorStats;
import l2s.commons.net.nio.impl.SelectorThread;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthServer {
    public static final int AUTH_SERVER_PROTOCOL = 4;
    private static final Logger _log = LoggerFactory.getLogger(AuthServer.class);
    private static AuthServer authServer;
    private GameServerCommunication _gameServerListener;
    private SelectorThread<L2LoginClient> _selectorThread;

    public static AuthServer getInstance() {
        return authServer;
    }

    public AuthServer() throws Exception {
        Config.initCrypt();
        GameServerManager.getInstance();
        L2LoginPacketHandler lph = new L2LoginPacketHandler();
        SelectorHelper sh = new SelectorHelper();
        SelectorConfig sc = new SelectorConfig();
        sc.AUTH_TIMEOUT = 60000L;
        SelectorStats sts = new SelectorStats();
        this._selectorThread = new SelectorThread(sc, sts, (IPacketHandler)lph, (IMMOExecutor)sh, (IClientFactory)sh, (IAcceptFilter)sh);
        this._gameServerListener = GameServerCommunication.getInstance();
        this._gameServerListener.openServerSocket(Config.GAME_SERVER_LOGIN_HOST.equals("*") ? null : InetAddress.getByName(Config.GAME_SERVER_LOGIN_HOST), Config.GAME_SERVER_LOGIN_PORT);
        this._gameServerListener.start();
        _log.info("Listening for gameservers on " + Config.GAME_SERVER_LOGIN_HOST + ":" + Config.GAME_SERVER_LOGIN_PORT);
        this._selectorThread.openServerSocket(Config.LOGIN_HOST.equals("*") ? null : InetAddress.getByName(Config.LOGIN_HOST), Config.PORT_LOGIN);
        this._selectorThread.start();
        _log.info("Listening for clients on " + Config.LOGIN_HOST + ":" + Config.PORT_LOGIN);
    }

    public GameServerCommunication getGameServerListener() {
        return this._gameServerListener;
    }

    public static void checkFreePorts() throws IOException {
        ServerSocket ss = null;
        try {
            ss = Config.LOGIN_HOST.equalsIgnoreCase("*") ? new ServerSocket(Config.PORT_LOGIN) : new ServerSocket(Config.PORT_LOGIN, 50, InetAddress.getByName(Config.LOGIN_HOST));
        }
        finally {
            if (ss != null) {
                try {
                    ss.close();
                }
                catch (Exception exception) {}
            }
        }
    }

    public static void main(String[] args) throws Exception {
        new File("./log/").mkdir();
        Config.load();
        AuthServer.checkFreePorts();
        Class.forName(Config.DATABASE_DRIVER).newInstance();
        DatabaseFactory.getInstance();
        AuthBanManager.getInstance().init();
        authServer = new AuthServer();
    }
}

