/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  l2s.commons.net.HostInfo
 *  org.apache.commons.lang3.StringUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.authserver.Config;
import l2s.authserver.database.DatabaseFactory;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.net.HostInfo;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameServerManager {
    public static final int SUCCESS_GS_REGISTER = 0;
    public static final int FAIL_GS_REGISTER_DIFF_KEYS = 1;
    public static final int FAIL_GS_REGISTER_ID_ALREADY_USE = 2;
    public static final int FAIL_GS_REGISTER_ERROR = 3;
    private static Logger _log = LoggerFactory.getLogger(GameServerManager.class);
    private static final GameServerManager _instance = new GameServerManager();
    private final Map<Integer, GameServer> _gameServers = new TreeMap<Integer, GameServer>();
    private final ReadWriteLock _lock = new ReentrantReadWriteLock();
    private final Lock _readLock = this._lock.readLock();
    private final Lock _writeLock = this._lock.writeLock();

    public static final GameServerManager getInstance() {
        return _instance;
    }

    public GameServerManager() {
        this.load();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void load() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT `id`, `ip`, `port`, `age_limit`, `pvp`, `max_players`, `type`, `brackets`, `key` FROM gameservers");
            rset = statement.executeQuery();
            while (rset.next()) {
                int id = rset.getInt("id");
                GameServer gs = new GameServer(id, rset.getString("ip"), rset.getInt("port"), rset.getString("key"));
                gs.setAgeLimit(rset.getInt("age_limit"));
                gs.setPvp(rset.getInt("pvp") > 0);
                gs.setMaxPlayers(rset.getInt("max_players"));
                gs.setServerType(rset.getInt("type"));
                gs.setShowingBrackets(rset.getInt("brackets") > 0);
                this._gameServers.put(id, gs);
            }
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        _log.info("Loaded " + this._gameServers.size() + " registered GameServer(s).");
    }

    public GameServer[] getGameServers() {
        this._readLock.lock();
        try {
            HashSet<GameServer> gameservers = new HashSet<GameServer>(this._gameServers.values());
            GameServer[] gameServerArray = gameservers.toArray(new GameServer[gameservers.size()]);
            return gameServerArray;
        }
        finally {
            this._readLock.unlock();
        }
    }

    public GameServer getGameServerById(int id) {
        this._readLock.lock();
        try {
            GameServer gameServer = this._gameServers.get(id);
            return gameServer;
        }
        finally {
            this._readLock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int registerGameServer(HostInfo host, GameServer gs) {
        this._writeLock.lock();
        try {
            GameServer pgs = this._gameServers.get(host.getId());
            if (pgs != null) {
                HostInfo phost = pgs.getHost(host.getId());
                if (phost == null || !StringUtils.equals((CharSequence)host.getKey(), (CharSequence)phost.getKey())) {
                    int n = 1;
                    return n;
                }
            } else if (!Config.ACCEPT_NEW_GAMESERVER) {
                int n = 2;
                return n;
            }
            if (pgs == null || !pgs.isAuthed()) {
                if (pgs != null) {
                    pgs.removeHost(host.getId());
                }
                this._gameServers.put(host.getId(), gs);
                int n = 0;
                return n;
            }
        }
        finally {
            this._writeLock.unlock();
        }
        return 3;
    }
}

