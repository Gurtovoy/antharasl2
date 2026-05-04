package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Map;
import l2s.commons.ban.BanBindType;
import l2s.commons.ban.BanInfo;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameBansDAO {
    private static final GameBansDAO INSTANCE = new GameBansDAO();
    private static final Logger LOGGER = LoggerFactory.getLogger(GameBansDAO.class);
    public static final String SELECT_SQL_QUERY = "SELECT bind_value, end_time, reason FROM game_bans WHERE bind_type=?";
    public static final String DELETE_SQL_QUERY = "DELETE FROM game_bans WHERE bind_type=? AND bind_value=?";
    public static final String INSERT_SQL_QUERY = "REPLACE INTO game_bans(bind_type, bind_value, end_time, reason) VALUES (?,?,?,?)";
    public static final String CLEAN_UP_SQL_QUERY = "DELETE FROM game_bans WHERE end_time < ? OR bind_value = ''";
    public static final String CLEAN_UP_BY_TYPE_SQL_QUERY = "DELETE FROM game_bans WHERE bind_type=?";

    public static GameBansDAO getInstance() {
        return INSTANCE;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void select(Map<String, BanInfo> bans, BanBindType bindType) {
        if (!bindType.isGame()) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(SELECT_SQL_QUERY);
            statement.setString(1, bindType.toString().toLowerCase());
            rset = statement.executeQuery();
            while (rset.next()) {
                String bindValue;
                int endTime = rset.getInt("end_time");
                if (endTime != -1 && (long)endTime < System.currentTimeMillis() / 1000L || StringUtils.isEmpty((CharSequence)(bindValue = rset.getString("bind_value")))) continue;
                String reason = rset.getString("reason");
                bans.put(bindValue, new BanInfo(endTime, reason));
            }
        }
        catch (Exception e) {
            try {
                LOGGER.error("GameBansDAO.select(Map,BanBindType): ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean insert(BanBindType bindType, String bindValue, BanInfo banInfo) {
        if (!bindType.isGame()) {
            return false;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(INSERT_SQL_QUERY);
            statement.setString(1, bindType.toString().toLowerCase());
            statement.setString(2, bindValue);
            statement.setInt(3, banInfo.getEndTime());
            statement.setString(4, banInfo.getReason());
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                LOGGER.error("GameBansDAO.insert(BanBindType,String,BanInfo): ", (Throwable)e);
                bl = false;
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return bl;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean delete(BanBindType bindType, String bindValue) {
        if (!bindType.isGame()) {
            return false;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.setString(1, bindType.toString().toLowerCase());
            statement.setString(2, bindValue);
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                LOGGER.error("GameBansDAO.delete(BanBindType,String): ", (Throwable)e);
                bl = false;
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return bl;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void cleanUp() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(CLEAN_UP_SQL_QUERY);
            statement.setInt(1, (int)(System.currentTimeMillis() / 1000L));
            statement.execute();
            for (BanBindType bindType : BanBindType.VALUES) {
                if (bindType.isGame()) continue;
                DbUtils.closeQuietly((Statement)statement);
                statement = con.prepareStatement(CLEAN_UP_BY_TYPE_SQL_QUERY);
                statement.setString(1, bindType.toString().toLowerCase());
                statement.execute();
            }
        }
        catch (Exception e) {
            try {
                LOGGER.error("GameBansDAO.cleanUp(): ", (Throwable)e);
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

