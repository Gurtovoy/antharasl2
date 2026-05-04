package l2s.gameserver.dao;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Block;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterBlockListDAO {
    private static final Logger _log = LoggerFactory.getLogger(CharacterBlockListDAO.class);
    private static final CharacterBlockListDAO _instance = new CharacterBlockListDAO();

    public static CharacterBlockListDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public TIntObjectMap<Block> select(Player owner) {
        TIntObjectHashMap map = new TIntObjectHashMap();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT b.target_Id, b.memo, c.char_name FROM character_blocklist b LEFT JOIN characters c ON b.target_Id = c.obj_Id WHERE b.obj_Id = ?");
            statement.setInt(1, owner.getObjectId());
            rset = statement.executeQuery();
            while (rset.next()) {
                String name = rset.getString("c.char_name");
                if (name == null) continue;
                int objectId = rset.getInt("b.target_Id");
                String memo = rset.getString("b.memo");
                map.put(objectId, new Block(objectId, name, memo));
            }
        }
        catch (Exception e) {
            try {
                _log.error("CharacterBlockListDAO.select(L2Player): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return map;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void insert(Player owner, int blockedObjectId) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO character_blocklist (obj_Id,target_Id) VALUES(?,?)");
            statement.setInt(1, owner.getObjectId());
            statement.setInt(2, blockedObjectId);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn(owner.getBlockList() + " could not add player to black list objectid: " + blockedObjectId, (Throwable)e);
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
    public void delete(Player owner, int blockedObjectId) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_blocklist WHERE obj_Id=? AND target_Id=?");
            statement.setInt(1, owner.getObjectId());
            statement.setInt(2, blockedObjectId);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn(owner.getBlockList() + " could not delete blocked objectId: " + blockedObjectId + " ownerId: " + owner.getObjectId(), (Throwable)e);
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
    public boolean updateMemo(Player owner, int blockedObjectId, String memo) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE character_blocklist SET memo=? WHERE obj_Id=? AND target_Id=?");
            statement.setString(1, memo);
            statement.setInt(2, owner.getObjectId());
            statement.setInt(3, blockedObjectId);
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn(owner.getBlockList() + " could not update memo objectid: " + blockedObjectId, (Throwable)e);
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

