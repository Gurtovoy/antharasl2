package l2s.authserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Map;
import l2s.authserver.database.DatabaseFactory;
import l2s.commons.ban.BanBindType;
import l2s.commons.ban.BanInfo;
import l2s.commons.dbutils.DbUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthBansDAO {
    private static final AuthBansDAO INSTANCE = new AuthBansDAO();
    private static final Logger LOGGER = LoggerFactory.getLogger(AuthBansDAO.class);
    public static final String SELECT_SQL_QUERY = "SELECT bind_value, end_time, reason FROM auth_bans WHERE bind_type=?";
    public static final String SELECT_ACCESS_LEVEL_SQL_QUERY = "SELECT login, access_level, ban_expire FROM accounts";
    public static final String DELETE_SQL_QUERY = "DELETE FROM auth_bans WHERE bind_type=? AND bind_value=?";
    public static final String INSERT_SQL_QUERY = "REPLACE INTO auth_bans(bind_type, bind_value, end_time, reason) VALUES (?,?,?,?)";
    public static final String CLEAN_UP_SQL_QUERY = "DELETE FROM auth_bans WHERE end_time < ? OR bind_value = ''";
    public static final String CLEAN_UP_BY_TYPE_SQL_QUERY = "DELETE FROM auth_bans WHERE bind_type=?";

    public static AuthBansDAO getInstance() {
        return INSTANCE;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void select(Map<String, BanInfo> bans, BanBindType bindType) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block8: {
            if (!bindType.isAuth()) {
                return;
            }
            con = null;
            statement = null;
            rset = null;
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
                if (bindType != BanBindType.LOGIN) break block8;
                DbUtils.closeQuietly((Statement)statement, (ResultSet)rset);
                statement = con.prepareStatement(SELECT_ACCESS_LEVEL_SQL_QUERY);
                rset = statement.executeQuery();
                while (rset.next()) {
                    int accessLevel = rset.getInt("access_level");
                    if (accessLevel < 0) {
                        bans.put(rset.getString("login"), new BanInfo(Integer.MAX_VALUE, ""));
                        continue;
                    }
                    int banExpire = rset.getInt("ban_expire");
                    if (banExpire != -1 && (long)banExpire <= System.currentTimeMillis() / 1000L) continue;
                    bans.put(rset.getString("login"), new BanInfo(banExpire, ""));
                }
            }
            catch (Exception e) {
                try {
                    LOGGER.error("AuthBansDAO.select(Map,BanBindType): ", (Throwable)e);
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
    public boolean insert(BanBindType bindType, String bindValue, BanInfo banInfo) {
        if (!bindType.isAuth()) {
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
                LOGGER.error("AuthBansDAO.insert(BanBindType,String,BanInfo): ", (Throwable)e);
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
        if (!bindType.isAuth()) {
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
                LOGGER.error("AuthBansDAO.delete(BanBindType,String): ", (Throwable)e);
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
                if (bindType.isAuth()) continue;
                DbUtils.closeQuietly((Statement)statement);
                statement = con.prepareStatement(CLEAN_UP_BY_TYPE_SQL_QUERY);
                statement.setString(1, bindType.toString().toLowerCase());
                statement.execute();
            }
        }
        catch (Exception e) {
            try {
                LOGGER.error("AuthBansDAO.cleanUp(): ", (Throwable)e);
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

