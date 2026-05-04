package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HardwareLimitsDAO {
    private static final Logger _log = LoggerFactory.getLogger(HardwareLimitsDAO.class);
    private static final HardwareLimitsDAO _instance = new HardwareLimitsDAO();
    public static final String SELECT_SQL_QUERY = "SELECT windows_limit, limit_expire FROM hardware_limits WHERE hardware=?";
    public static final String DELETE_SQL_QUERY = "DELETE FROM hardware_limits WHERE hardware=?";
    public static final String INSERT_SQL_QUERY = "REPLACE INTO hardware_limits(hardware, windows_limit, limit_expire) VALUES (?,?,?)";
    private final Map<String, int[]> _cache = new ConcurrentHashMap<String, int[]>();

    public static HardwareLimitsDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int[] select(String hardware) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        int[] limits;
        block6: {
            if (hardware == null || hardware.isEmpty()) {
                return new int[2];
            }
            limits = this._cache.get(hardware);
            if (limits != null) {
                return limits;
            }
            limits = new int[2];
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement(SELECT_SQL_QUERY);
                statement.setString(1, hardware);
                rset = statement.executeQuery();
                if (!rset.next()) break block6;
                limits[0] = rset.getInt("windows_limit");
                limits[1] = rset.getInt("limit_expire");
            }
            catch (Exception e) {
                try {
                    _log.info("HardwareLimitsDAO.select(String): " + e, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    this._cache.put(hardware, limits);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
                this._cache.put(hardware, limits);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        this._cache.put(hardware, limits);
        return limits;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void delete(String hardware) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.setString(1, hardware);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.info("HardwareLimitsDAO.delete(String): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                this._cache.remove(hardware);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            this._cache.remove(hardware);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this._cache.remove(hardware);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void insert(String hardware, int limit, int expire) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(INSERT_SQL_QUERY);
            statement.setString(1, hardware);
            statement.setInt(2, limit);
            statement.setInt(3, expire);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.info("HardwareLimitsDAO.insert(String, int): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                this._cache.put(hardware, new int[]{limit, expire});
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            this._cache.put(hardware, new int[]{limit, expire});
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this._cache.put(hardware, new int[]{limit, expire});
    }
}

