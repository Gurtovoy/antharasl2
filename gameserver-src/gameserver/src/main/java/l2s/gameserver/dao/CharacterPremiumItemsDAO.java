/*
 * This file was originally decompiled from L2S rev.[31495].
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
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.PremiumItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterPremiumItemsDAO {
    private static final Logger _log = LoggerFactory.getLogger(CharacterPremiumItemsDAO.class);
    private static final CharacterPremiumItemsDAO _instance = new CharacterPremiumItemsDAO();

    public static CharacterPremiumItemsDAO getInstance() {
        return _instance;
    }

    
    public List<PremiumItem> select(Player owner) {
        ArrayList<PremiumItem> list = new ArrayList<PremiumItem>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT receive_time, item_id, item_count, sender FROM character_premium_items WHERE char_id = ?");
            statement.setInt(1, owner.getObjectId());
            rset = statement.executeQuery();
            while (rset.next()) {
                int receive_time = rset.getInt("receive_time");
                int item_id = rset.getInt("item_id");
                long item_count = rset.getLong("item_count");
                String sender = rset.getString("sender");
                list.add(new PremiumItem(receive_time, item_id, item_count, sender));
            }
        }
        catch (Exception e) {
            try {
                _log.error("CharacterPremiumItemsDAO.select(L2Player): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return list;
    }

    
    public boolean insert(Player owner, PremiumItem item) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO character_premium_items (char_id,receive_time,item_id,item_count,sender) VALUES(?,?,?,?,?)");
            statement.setInt(1, owner.getObjectId());
            statement.setInt(2, item.getReceiveTime());
            statement.setInt(3, item.getItemId());
            statement.setLong(4, item.getItemCount());
            statement.setString(5, item.getSender());
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn(owner.getBlockList() + " could not add item to premium item list: " + item, (Throwable)e);
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

    
    public boolean delete(Player owner, PremiumItem item) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_premium_items WHERE char_id = ? AND receive_time = ? AND item_id = ? AND item_count = ? AND sender = ?");
            statement.setInt(1, owner.getObjectId());
            statement.setInt(2, item.getReceiveTime());
            statement.setInt(3, item.getItemId());
            statement.setLong(4, item.getItemCount());
            statement.setString(5, item.getSender());
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn(owner.getBlockList() + " could not delete item: " + item + " ownerId: " + owner.getObjectId(), (Throwable)e);
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

    
    public boolean update(Player owner, PremiumItem item, long count) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE character_premium_items SET item_count = ? WHERE char_id = ? AND receive_time = ? AND item_id = ? AND item_count = ? AND sender = ?");
            statement.setLong(1, count);
            statement.setInt(2, owner.getObjectId());
            statement.setInt(3, item.getReceiveTime());
            statement.setInt(4, item.getItemId());
            statement.setLong(5, item.getItemCount());
            statement.setString(6, item.getSender());
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn(owner.getBlockList() + " could not update item: " + item, (Throwable)e);
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

