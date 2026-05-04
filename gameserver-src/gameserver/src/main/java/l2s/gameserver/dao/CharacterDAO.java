/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.HashIntSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CharacterDAO {
    private static final Logger _log = LoggerFactory.getLogger(CharacterDAO.class);
    private static CharacterDAO _instance = new CharacterDAO();

    public static CharacterDAO getInstance() {
        return _instance;
    }

    
    public void deleteCharByObjId(int objid) {
        if (objid < 0) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM characters WHERE obj_Id=?");
            statement.setInt(1, objid);
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

    
    public boolean insert(Player player) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO `characters` (account_name, obj_Id, char_name, face, beautyFace, hairStyle, beautyHairStyle, hairColor, beautyHairColor, sex, karma, pvpkills, pkkills, clanid, createtime, deletetime, title, accesslevel, online, leaveclan, deleteclan, nochannel, pledge_type, pledge_rank, lvl_joined_academy, apprentice, used_world_chat_points, hide_head_accessories) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
            statement.setString(1, player.getAccountName());
            statement.setInt(2, player.getObjectId());
            statement.setString(3, player.getName());
            statement.setInt(4, player.getFace());
            statement.setInt(5, player.getBeautyFace());
            statement.setInt(6, player.getHairStyle());
            statement.setInt(7, player.getBeautyHairStyle());
            statement.setInt(8, player.getHairColor());
            statement.setInt(9, player.getBeautyHairColor());
            statement.setInt(10, player.getSex().ordinal());
            statement.setInt(11, player.getKarma());
            statement.setInt(12, player.getPvpKills());
            statement.setInt(13, player.getPkKills());
            statement.setInt(14, player.getClanId());
            statement.setLong(15, player.getCreateTime() / 1000L);
            statement.setInt(16, player.getDeleteTimer());
            statement.setString(17, player.getTitle());
            statement.setInt(18, player.getAccessLevel());
            statement.setInt(19, player.isOnline() ? 1 : 0);
            statement.setLong(20, player.getLeaveClanTime() / 1000L);
            statement.setLong(21, player.getDeleteClanTime() / 1000L);
            statement.setLong(22, player.getNoChannel() > 0L ? player.getNoChannel() / 1000L : player.getNoChannel());
            statement.setInt(23, player.getPledgeType());
            statement.setInt(24, player.getPowerGrade());
            statement.setInt(25, player.getLvlJoinedAcademy());
            statement.setInt(26, player.getApprentice());
            statement.setInt(27, player.getUsedWorldChatPoints());
            statement.setInt(28, player.hideHeadAccessories() ? 1 : 0);
            statement.executeUpdate();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.error("", (Throwable)e);
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

    
    public int getObjectIdByName(String name) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        int result;
        block4: {
            result = 0;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT obj_Id FROM characters WHERE char_name=?");
                statement.setString(1, name);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                result = rset.getInt(1);
            }
            catch (Exception e) {
                try {
                    _log.error("CharNameTable.getObjectIdByName(String): " + e, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return result;
    }

    
    public String getNameByObjectId(int objectId, boolean nullable) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        String result;
        block4: {
            result = nullable ? null : "";
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT char_name FROM characters WHERE obj_Id=?");
                statement.setInt(1, objectId);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                result = rset.getString(1);
            }
            catch (Exception e) {
                try {
                    _log.error("CharNameTable.getObjectIdByName(int): " + e, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return result;
    }

    public String getNameByObjectId(int objectId) {
        return this.getNameByObjectId(objectId, false);
    }

    
    public String getAccNameByName(String n) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        String result;
        block4: {
            result = "";
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT account_name FROM characters WHERE char_name=? LIMIT 1");
                statement.setString(1, n);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                result = rset.getString(1);
            }
            catch (Exception e) {
                try {
                    _log.error("CharNameTable.getAccNameByName(String): " + e, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return result;
    }

    
    public int accountCharNumber(String account) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        int number;
        block4: {
            number = 0;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT COUNT(char_name) FROM characters WHERE account_name=?");
                statement.setString(1, account);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                number = rset.getInt(1);
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
        return number;
    }

    public List<String> getPlayersNameByAccount(String account, int minAccessLevel) {
        ArrayList<String> charNames = new ArrayList<String>(8);
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement statement = con.prepareStatement("SELECT char_name FROM characters WHERE account_name=?" + (minAccessLevel > Integer.MIN_VALUE ? " AND accesslevel >= 0" : ""));){
            statement.setString(1, account);
            try (ResultSet rset = statement.executeQuery();){
                while (rset.next()) {
                    charNames.add(rset.getString("char_name"));
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        catch (SQLException e) {
            _log.error("Error while loading Char Names From Account: " + account, (Throwable)e);
        }
        return charNames;
    }

    public List<String> getPlayersNameByAccount(String account) {
        return this.getPlayersNameByAccount(account, Integer.MIN_VALUE);
    }

    public List<Integer> getPlayersIdByAccount(String account, int minAccessLevel) {
        ArrayList<Integer> charIds = new ArrayList<Integer>(8);
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement statement = con.prepareStatement("SELECT obj_Id FROM characters WHERE account_name=?" + (minAccessLevel > Integer.MIN_VALUE ? " AND accesslevel >= 0" : ""));){
            statement.setString(1, account);
            try (ResultSet rset = statement.executeQuery();){
                while (rset.next()) {
                    charIds.add(rset.getInt("obj_Id"));
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
        catch (SQLException e) {
            _log.error("Error while loading Char IDs From Account: " + account, (Throwable)e);
        }
        return charIds;
    }

    public List<Integer> getPlayersIdByAccount(String account) {
        return this.getPlayersIdByAccount(account, Integer.MIN_VALUE);
    }

    
    public IntSet getAllPlayersObjectIds() {
        HashIntSet set = new HashIntSet();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT obj_Id FROM characters");
            rset = statement.executeQuery();
            while (rset.next()) {
                set.add(rset.getInt(1));
            }
        }
        catch (Exception e) {
            try {
                e.printStackTrace();
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return set;
    }

    
    public String getLastIPByName(String n) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        String ip;
        block4: {
            ip = null;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT last_ip FROM characters WHERE char_name=? LIMIT 1");
                statement.setString(1, n);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                ip = rset.getString(1);
            }
            catch (Exception e) {
                try {
                    e.printStackTrace();
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return ip != null ? ip : "";
    }

    
    public String getLastHWIDByName(String n) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        String hwid;
        block4: {
            hwid = null;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT last_hwid FROM characters WHERE char_name=? LIMIT 1");
                statement.setString(1, n);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                hwid = rset.getString(1);
            }
            catch (Exception e) {
                try {
                    e.printStackTrace();
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return hwid != null ? hwid : "";
    }
}

