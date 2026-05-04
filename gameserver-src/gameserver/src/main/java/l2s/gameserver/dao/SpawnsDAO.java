/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.spawn.PeriodOfDay;
import l2s.gameserver.templates.spawn.SpawnNpcInfo;
import l2s.gameserver.templates.spawn.SpawnPoint;
import l2s.gameserver.templates.spawn.SpawnTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SpawnsDAO {
    private static final Logger _log = LoggerFactory.getLogger(SpawnsDAO.class);
    private static final SpawnsDAO _instance = new SpawnsDAO();
    public static final String SELECT_SQL_QUERY = "SELECT npc_id, x, y, z, heading, respawn, count FROM spawns";
    public static final String DELETE_SQL_QUERY = "DELETE FROM spawns WHERE count <= 0";
    public static final String INSERT_SQL_QUERY = "REPLACE INTO spawns (npc_id, x, y, z, heading, respawn, count) VALUES (?,?,?,?,?,?,?)";
    public static final String REDUCE_COUNT_SQL_QUERY = "UPDATE spawns SET count = count - 1 WHERE npc_id = ? AND x = ? AND y = ? AND z = ? LIMIT 1";

    public static SpawnsDAO getInstance() {
        return _instance;
    }

    
    public List<SpawnTemplate> restore() {
        ArrayList<SpawnTemplate> result = new ArrayList<SpawnTemplate>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(SELECT_SQL_QUERY);
            rset = statement.executeQuery();
            while (rset.next()) {
                int npcId = rset.getInt("npc_id");
                int x = rset.getInt("x");
                int y = rset.getInt("y");
                int z = rset.getInt("z");
                int heading = rset.getInt("heading");
                int respawn = rset.getInt("respawn");
                int count = rset.getInt("count");
                SpawnTemplate template = new SpawnTemplate("from_database", PeriodOfDay.NONE, count, respawn, 0, null);
                template.addSpawnPoint(new SpawnPoint(x, y, z, heading, 100.0));
                template.addNpc(new SpawnNpcInfo(npcId, 0, StatsSet.EMPTY, Collections.emptyList()));
                result.add(template);
            }
        }
        catch (Exception e) {
            try {
                _log.error("SpawnsDAO:restore()", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return result;
    }

    
    public boolean insert(int npcId, int x, int y, int z, int heading, int respawn, int count) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(INSERT_SQL_QUERY);
            statement.setInt(1, npcId);
            statement.setInt(2, x);
            statement.setInt(3, y);
            statement.setInt(4, z);
            statement.setInt(5, heading);
            statement.setInt(6, respawn);
            statement.setInt(7, count);
            statement.executeUpdate();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.error("SpawnsDAO:insert(npcId,x,y,z,heading,respawn,count)", (Throwable)e);
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

    
    public boolean delete(NpcInstance npc) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(REDUCE_COUNT_SQL_QUERY);
            statement.setInt(1, npc.getNpcId());
            statement.setInt(2, npc.getSpawnedLoc().x);
            statement.setInt(3, npc.getSpawnedLoc().y);
            statement.setInt(4, npc.getSpawnedLoc().z);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.error("SpawnsDAO:delete(npc)", (Throwable)e);
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
}

