package l2s.authserver.accounts;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.authserver.database.DatabaseFactory;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.net.utils.Net;
import l2s.commons.net.utils.NetList;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Account {
    private static final Logger _log = LoggerFactory.getLogger(Account.class);
    private final String login;
    private String passwordHash;
    private String allowedIP;
    private String allowedHwid;
    private NetList allowedIpList = new NetList();
    private int accessLevel;
    private int banExpire;
    private int bonus;
    private int bonusExpire;
    private String lastIP;
    private int lastAccess;
    private int lastServer;
    private int points;
    private long phoneNumber;
    private IntObjectMap<Pair<Integer, int[]>> _serversInfo = new HashIntObjectMap(2);

    public Account(String login) {
        this.login = login;
    }

    public String getLogin() {
        return this.login;
    }

    public String getPasswordHash() {
        return this.passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getAllowedIP() {
        return this.allowedIP;
    }

    public String getAllowedHwid() {
        return this.allowedHwid;
    }

    public boolean isAllowedIP(String ip) {
        return this.allowedIpList.isEmpty() || this.allowedIpList.matches(ip);
    }

    public void setAllowedIP(String allowedIP) {
        String[] masks;
        this.allowedIpList.clear();
        this.allowedIP = allowedIP;
        if (allowedIP.isEmpty()) {
            return;
        }
        for (String mask : masks = allowedIP.split("[\\s,;]+")) {
            try {
                this.allowedIpList.add(Net.valueOf((String)mask));
            }
            catch (Exception e) {
                _log.error("", (Throwable)e);
            }
        }
    }

    public void setAllowedHwid(String allowedHwid) {
        this.allowedHwid = allowedHwid;
    }

    public int getAccessLevel() {
        return this.accessLevel;
    }

    public void setAccessLevel(int accessLevel) {
        this.accessLevel = accessLevel;
    }

    public int getBonus() {
        return this.bonus;
    }

    public void setBonus(int bonus) {
        this.bonus = bonus;
    }

    public int getBonusExpire() {
        return this.bonusExpire;
    }

    public void setBonusExpire(int bonusExpire) {
        this.bonusExpire = bonusExpire;
    }

    public int getBanExpire() {
        return this.banExpire;
    }

    public void setBanExpire(int banExpire) {
        this.banExpire = banExpire;
    }

    public void setLastIP(String lastIP) {
        this.lastIP = lastIP;
    }

    public String getLastIP() {
        return this.lastIP;
    }

    public int getLastAccess() {
        return this.lastAccess;
    }

    public void setLastAccess(int lastAccess) {
        this.lastAccess = lastAccess;
    }

    public int getLastServer() {
        return this.lastServer;
    }

    public void setLastServer(int lastServer) {
        this.lastServer = lastServer;
    }

    public void addAccountInfo(int serverId, int size, int[] deleteChars) {
        this._serversInfo.put(serverId, new ImmutablePair<>(size, deleteChars));
    }

    public Pair<Integer, int[]> getAccountInfo(int serverId) {
        return (Pair)this._serversInfo.get(serverId);
    }

    public void setPoints(int points) {
        this.points = points;
    }

    public int getPoints() {
        return this.points;
    }

    public void setPhoneNumber(long phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public long getPhoneNumber() {
        return this.phoneNumber;
    }

    public String toString() {
        return this.login;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restore() {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block4: {
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT password, access_level, ban_expire, allow_ip, allow_hwid, bonus, bonus_expire, last_server, last_ip, last_access, points, phone_nubmer FROM accounts WHERE login = ?");
                statement.setString(1, this.login);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                this.setPasswordHash(rset.getString("password"));
                this.setAccessLevel(rset.getInt("access_level"));
                this.setBanExpire(rset.getInt("ban_expire"));
                this.setAllowedIP(rset.getString("allow_ip"));
                this.setAllowedHwid(rset.getString("allow_hwid"));
                this.setBonus(rset.getInt("bonus"));
                this.setBonusExpire(rset.getInt("bonus_expire"));
                this.setLastServer(rset.getInt("last_server"));
                this.setLastIP(rset.getString("last_ip"));
                this.setLastAccess(rset.getInt("last_access"));
                this.setPoints(rset.getInt("points"));
                this.setPhoneNumber(rset.getLong("phone_nubmer"));
            }
            catch (Exception e) {
                try {
                    _log.error("", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void save() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO accounts (login, password) VALUES(?,?)");
            statement.setString(1, this.getLogin());
            statement.setString(2, this.getPasswordHash());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void update() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE accounts SET password = ?, access_level = ?, ban_expire = ?, allow_ip = ?, allow_hwid=?, bonus = ?, bonus_expire = ?, last_server = ?, last_ip = ?, last_access = ?, points = ? WHERE login = ?");
            statement.setString(1, this.getPasswordHash());
            statement.setInt(2, this.getAccessLevel());
            statement.setInt(3, this.getBanExpire());
            statement.setString(4, this.getAllowedIP());
            statement.setString(5, this.getAllowedHwid());
            statement.setInt(6, this.getBonus());
            statement.setInt(7, this.getBonusExpire());
            statement.setInt(8, this.getLastServer());
            statement.setString(9, this.getLastIP());
            statement.setInt(10, this.getLastAccess());
            statement.setInt(11, this.getPoints());
            statement.setString(12, this.getLogin());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void reducePoints(String account, int count) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE accounts SET points = (points - ?) WHERE login = ?");
            statement.setInt(1, count);
            statement.setString(2, account);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }
}

