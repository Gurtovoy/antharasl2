/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.actor.instances.player.CharacterVariable;
import l2s.gameserver.utils.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterVariablesDAO {
    private static final Logger _log = LoggerFactory.getLogger(CharacterVariablesDAO.class);
    private static final CharacterVariablesDAO _instance = new CharacterVariablesDAO();
    public static final String SELECT_SQL_QUERY = "SELECT name, value, expire_time FROM character_variables WHERE obj_id = ?";
    public static final String SELECT_FROM_PLAYER_SQL_QUERY = "SELECT value, expire_time FROM character_variables WHERE obj_id = ? AND name = ?";
    public static final String DELETE_SQL_QUERY = "DELETE FROM character_variables WHERE obj_id = ? AND name = ? LIMIT 1";
    public static final String DELETE_ALL_SQL_QUERY = "DELETE FROM character_variables WHERE name = ?";
    public static final String DELETE_EXPIRED_SQL_QUERY = "DELETE FROM character_variables WHERE expire_time > 0 AND expire_time < ?";
    public static final String INSERT_SQL_QUERY = "REPLACE INTO character_variables (obj_id, name, value, expire_time) VALUES (?,?,?,?)";

    public CharacterVariablesDAO() {
        this.deleteExpiredVars();
    }

    public static CharacterVariablesDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void deleteExpiredVars() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_EXPIRED_SQL_QUERY);
            statement.setLong(1, System.currentTimeMillis());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CharacterVariablesDAO:deleteExpiredVars()", (Throwable)e);
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
    public boolean delete(int playerObjId, String varName) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.setInt(1, playerObjId);
            statement.setString(2, varName);
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.error("CharacterVariablesDAO:delete(playerObjId,varName)", (Throwable)e);
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
    public boolean delete(String varName) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_ALL_SQL_QUERY);
            statement.setString(1, varName);
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.error("CharacterVariablesDAO:delete(varName)", (Throwable)e);
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
    public boolean insert(int playerObjId, CharacterVariable var) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(INSERT_SQL_QUERY);
            statement.setInt(1, playerObjId);
            statement.setString(2, var.getName());
            statement.setString(3, var.getValue());
            statement.setLong(4, var.getExpireTime());
            statement.executeUpdate();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.error("CharacterVariablesDAO:insert(playerObjId,var)", (Throwable)e);
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
    public List<CharacterVariable> restore(int playerObjId) {
        ArrayList<CharacterVariable> result = new ArrayList<CharacterVariable>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(SELECT_SQL_QUERY);
            statement.setInt(1, playerObjId);
            rset = statement.executeQuery();
            while (rset.next()) {
                long expireTime = rset.getLong("expire_time");
                if (expireTime > 0L && expireTime < System.currentTimeMillis()) continue;
                result.add(new CharacterVariable(rset.getString("name"), Strings.stripSlashes(rset.getString("value")), expireTime));
            }
        }
        catch (Exception e) {
            try {
                _log.error("CharacterVariablesDAO:restore(playerObjId)", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public String getVarFromPlayer(int playerObjId, String var) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        String value;
        block4: {
            value = null;
            con = null;
            statement = null;
            rset = null;
            try {
                long expireTime;
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement(SELECT_FROM_PLAYER_SQL_QUERY);
                statement.setInt(1, playerObjId);
                statement.setString(2, var);
                rset = statement.executeQuery();
                if (!rset.next() || (expireTime = rset.getLong("expire_time")) > 0L && expireTime < System.currentTimeMillis()) break block4;
                value = Strings.stripSlashes(rset.getString("value"));
            }
            catch (Exception e) {
                try {
                    _log.error("CharacterVariablesDAO:getVarFromPlayer(playerObjId,var)", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return value;
    }
}

