package l2s.authserver.network.gamecomm;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import l2s.authserver.database.DatabaseFactory;
import l2s.authserver.network.gamecomm.GameServerConnection;
import l2s.authserver.network.gamecomm.SendablePacket;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.net.HostInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameServer {
    private static final Logger _log = LoggerFactory.getLogger(GameServer.class);
    private final TIntObjectMap<HostInfo> _hosts = new TIntObjectHashMap();
    private int _serverType;
    private int _ageLimit;
    private int _protocol;
    private boolean _isOnline;
    private boolean _isPvp;
    private boolean _isShowingBrackets;
    private boolean _isGmOnly;
    private int _maxPlayers;
    private GameServerConnection _conn;
    private boolean _isAuthed;
    private Set<String> _accounts = new CopyOnWriteArraySet<String>();

    public GameServer(GameServerConnection conn) {
        this._conn = conn;
    }

    public GameServer(int id, String ip, int port, String key) {
        this._conn = null;
        this.addHost(new HostInfo(id, ip, port, key));
    }

    public void addHost(HostInfo host) {
        this._hosts.put(host.getId(), host);
    }

    public HostInfo removeHost(int id) {
        return (HostInfo)this._hosts.remove(id);
    }

    public HostInfo getHost(int id) {
        return (HostInfo)this._hosts.get(id);
    }

    public HostInfo[] getHosts() {
        return (HostInfo[])this._hosts.values(new HostInfo[this._hosts.size()]);
    }

    public void setAuthed(boolean isAuthed) {
        this._isAuthed = isAuthed;
    }

    public boolean isAuthed() {
        return this._isAuthed;
    }

    public void setConnection(GameServerConnection conn) {
        this._conn = conn;
    }

    public GameServerConnection getConnection() {
        return this._conn;
    }

    public void setMaxPlayers(int maxPlayers) {
        this._maxPlayers = maxPlayers;
    }

    public int getMaxPlayers() {
        return this._maxPlayers;
    }

    public int getOnline() {
        return this._accounts.size();
    }

    public Set<String> getAccounts() {
        return this._accounts;
    }

    public void addAccount(String account) {
        this._accounts.add(account);
    }

    public void removeAccount(String account) {
        this._accounts.remove(account);
    }

    public void setDown() {
        this.setAuthed(false);
        this.setConnection(null);
        this.setOnline(false);
        this._accounts.clear();
    }

    public void sendPacket(SendablePacket packet) {
        GameServerConnection conn = this.getConnection();
        if (conn != null) {
            conn.sendPacket(packet);
        }
    }

    public int getServerType() {
        return this._serverType;
    }

    public boolean isOnline() {
        return this._isOnline;
    }

    public void setOnline(boolean online) {
        this._isOnline = online;
    }

    public void setServerType(int serverType) {
        this._serverType = serverType;
    }

    public boolean isPvp() {
        return this._isPvp;
    }

    public void setPvp(boolean pvp) {
        this._isPvp = pvp;
    }

    public boolean isShowingBrackets() {
        return this._isShowingBrackets;
    }

    public void setShowingBrackets(boolean showingBrackets) {
        this._isShowingBrackets = showingBrackets;
    }

    public boolean isGmOnly() {
        return this._isGmOnly;
    }

    public void setGmOnly(boolean gmOnly) {
        this._isGmOnly = gmOnly;
    }

    public int getAgeLimit() {
        return this._ageLimit;
    }

    public void setAgeLimit(int ageLimit) {
        this._ageLimit = ageLimit;
    }

    public int getProtocol() {
        return this._protocol;
    }

    public void setProtocol(int protocol) {
        this._protocol = protocol;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean store() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            for (HostInfo host : this._hosts.valueCollection()) {
                statement = con.prepareStatement("REPLACE INTO gameservers (`id`, `ip`, `port`, `age_limit`, `pvp`, `max_players`, `type`, `brackets`, `key`) VALUES(?,?,?,?,?,?,?,?,?)");
                int i = 0;
                statement.setInt(++i, host.getId());
                statement.setString(++i, host.getAddress());
                statement.setShort(++i, (short)host.getPort());
                statement.setByte(++i, (byte)this.getAgeLimit());
                statement.setByte(++i, (byte)(this.isPvp() ? 1 : 0));
                statement.setShort(++i, (short)this.getMaxPlayers());
                statement.setInt(++i, this.getServerType());
                statement.setByte(++i, (byte)(this.isShowingBrackets() ? 1 : 0));
                statement.setString(++i, host.getKey());
                statement.execute();
                DbUtils.closeQuietly((Statement)statement);
            }
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.error("Error while store gameserver: " + e, (Throwable)e);
                bl = false;
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return bl;
        }
        DbUtils.closeQuietly((Connection)con, statement);
        return true;
    }
}

