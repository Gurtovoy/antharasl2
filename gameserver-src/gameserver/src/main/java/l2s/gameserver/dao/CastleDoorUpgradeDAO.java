package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CastleDoorUpgradeDAO {
    private static final CastleDoorUpgradeDAO _instance = new CastleDoorUpgradeDAO();
    private static final Logger _log = LoggerFactory.getLogger(CastleDoorUpgradeDAO.class);
    public static final String SELECT_SQL_QUERY = "SELECT hp FROM castle_door_upgrade WHERE door_id=?";
    public static final String REPLACE_SQL_QUERY = "REPLACE INTO castle_door_upgrade (door_id, hp) VALUES (?,?)";
    public static final String DELETE_SQL_QUERY = "DELETE FROM castle_door_upgrade WHERE door_id=?";

    public static CastleDoorUpgradeDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int load(int doorId) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block4: {
            int n = 0;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement(SELECT_SQL_QUERY);
                statement.setInt(1, doorId);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                n = rset.getInt("hp");
            }
            catch (Exception e) {
                try {
                    _log.error("CastleDoorUpgradeDAO:load(int): " + e, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            return n;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return 0;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void insert(int uId, int val) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(REPLACE_SQL_QUERY);
            statement.setInt(1, uId);
            statement.setInt(2, val);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CastleDoorUpgradeDAO:insert(int, int): " + e, (Throwable)e);
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
    public void delete(int uId) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.setInt(1, uId);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CastleDoorUpgradeDAO:delete(int): " + e, (Throwable)e);
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

