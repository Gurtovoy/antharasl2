/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.napile.primitive.pair.IntObjectPair
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Collection;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.utils.SqlBatch;
import org.napile.primitive.pair.IntObjectPair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterGroupReuseDAO {
    private static final Logger _log = LoggerFactory.getLogger(CharacterGroupReuseDAO.class);
    private static CharacterGroupReuseDAO _instance = new CharacterGroupReuseDAO();
    public static final String DELETE_SQL_QUERY = "DELETE FROM character_group_reuse WHERE object_id=?";
    public static final String SELECT_SQL_QUERY = "SELECT * FROM character_group_reuse WHERE object_id=?";
    public static final String INSERT_SQL_QUERY = "REPLACE INTO `character_group_reuse` (`object_id`,`reuse_group`,`item_id`,`end_time`,`reuse`) VALUES";

    public static CharacterGroupReuseDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void select(Player player) {
        long curTime = System.currentTimeMillis();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(SELECT_SQL_QUERY);
            statement.setInt(1, player.getObjectId());
            rset = statement.executeQuery();
            while (rset.next()) {
                int group = rset.getInt("reuse_group");
                int item_id = rset.getInt("item_id");
                long endTime = rset.getLong("end_time");
                long reuse = rset.getLong("reuse");
                if (endTime - curTime <= 500L) continue;
                TimeStamp stamp = new TimeStamp(item_id, endTime, reuse);
                player.addSharedGroupReuse(group, stamp);
            }
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.setInt(1, player.getObjectId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CharacterGroupReuseDAO.select(Player):", (Throwable)e);
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
    public void insert(Player player) {
        PreparedStatement statement;
        Connection con;
        block7: {
            Collection<IntObjectPair<TimeStamp>> reuses;
            block6: {
                con = null;
                statement = null;
                try {
                    con = DatabaseFactory.getInstance().getConnection();
                    statement = con.prepareStatement(DELETE_SQL_QUERY);
                    statement.setInt(1, player.getObjectId());
                    statement.execute();
                } catch (java.sql.SQLException e) {
                    _log.error("CharacterGroupReuseDAO:insert(Player): " + e, e);
                    DbUtils.closeQuietly((Connection)con, (Statement)statement);
                    return;
                }
                reuses = player.getSharedGroupReuses();
                if (!reuses.isEmpty()) break block6;
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
                return;
            }
            try {
                SqlBatch b = new SqlBatch(INSERT_SQL_QUERY);
                for (IntObjectPair<TimeStamp> entry : reuses) {
                    int group = entry.getKey();
                    TimeStamp timeStamp = (TimeStamp)entry.getValue();
                    if (!timeStamp.hasNotPassed()) continue;
                    StringBuilder sb = new StringBuilder("(");
                    sb.append(player.getObjectId()).append(",");
                    sb.append(group).append(",");
                    sb.append(timeStamp.getId()).append(",");
                    sb.append(timeStamp.getEndTime()).append(",");
                    sb.append(timeStamp.getReuseBasic()).append(")");
                    b.write(sb.toString());
                }
                if (b.isEmpty()) break block7;
                statement.executeUpdate(b.close());
            }
            catch (Exception e) {
                try {
                    _log.error("CharacterGroupReuseDAO.insert(Player):", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }
}

