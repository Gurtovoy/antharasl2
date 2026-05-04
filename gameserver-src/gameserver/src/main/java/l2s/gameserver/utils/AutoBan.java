/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.network.l2.components.CustomMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class AutoBan {
    private static final Logger _log = LoggerFactory.getLogger(AutoBan.class);

    
    public static boolean isBanned(int ObjectId) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        boolean res;
        block4: {
            res = false;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT MAX(endban) AS endban FROM bans WHERE obj_Id=? AND endban IS NOT NULL");
                statement.setInt(1, ObjectId);
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                Long endban = rset.getLong("endban") * 1000L;
                res = endban > System.currentTimeMillis();
            }
            catch (Exception e) {
                try {
                    _log.warn("Could not restore ban data: " + e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return res;
    }

    
    public static void Banned(Player actor, int period, String msg, String GM) {
        int endban = 0;
        if (period == -1) {
            endban = Integer.MAX_VALUE;
        } else if (period > 0) {
            Calendar end = Calendar.getInstance();
            end.add(5, period);
            endban = (int)(end.getTimeInMillis() / 1000L);
        } else {
            _log.warn("Negative ban period: " + period);
            return;
        }
        String date = new SimpleDateFormat("yy.MM.dd H:mm:ss").format(new Date());
        String enddate = new SimpleDateFormat("yy.MM.dd H:mm:ss").format(new Date((long)endban * 1000L));
        if ((long)endban * 1000L <= Calendar.getInstance().getTimeInMillis()) {
            _log.warn("Negative ban period | From " + date + " to " + enddate);
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO bans (account_name, obj_id, baned, unban, reason, GM, endban) VALUES(?,?,?,?,?,?,?)");
            statement.setString(1, actor.getAccountName());
            statement.setInt(2, actor.getObjectId());
            statement.setString(3, date);
            statement.setString(4, enddate);
            statement.setString(5, msg);
            statement.setString(6, GM);
            statement.setLong(7, endban);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("could not store bans data:" + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public static boolean Banned(String actor, int acc_level, int period, String msg, String GM) {
        int obj_id = CharacterDAO.getInstance().getObjectIdByName(actor);
        boolean res = obj_id > 0;
        if (!res) {
            return false;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET accesslevel=? WHERE obj_Id=?");
            statement.setInt(1, acc_level);
            statement.setInt(2, obj_id);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            if (acc_level < 0) {
                int endban = 0;
                if (period == -1) {
                    endban = 0x7FFFFFFF;
                } else if (period > 0) {
                    Calendar end = Calendar.getInstance();
                    end.add(5, period);
                    endban = (int)(end.getTimeInMillis() / 1000L);
                } else {
                    AutoBan._log.warn("Negative ban period: " + period);
                    DbUtils.closeQuietly((Connection)con, (Statement)statement);
                    return false;
                }
                String date = new SimpleDateFormat("yy.MM.dd H:mm:ss").format(new Date());
                String enddate = new SimpleDateFormat("yy.MM.dd H:mm:ss").format(new Date((long)endban * 1000L));
                if ((long)endban * 1000L <= Calendar.getInstance().getTimeInMillis()) {
                    AutoBan._log.warn("Negative ban period | From " + date + " to " + enddate);
                    DbUtils.closeQuietly((Connection)con, (Statement)statement);
                    return false;
                }
                statement = con.prepareStatement("INSERT INTO bans (obj_id, baned, unban, reason, GM, endban) VALUES(?,?,?,?,?,?)");
                statement.setInt(1, obj_id);
                statement.setString(2, date);
                statement.setString(3, enddate);
                statement.setString(4, msg);
                statement.setString(5, GM);
                statement.setLong(6, endban);
                statement.execute();
            } else {
                statement = con.prepareStatement("DELETE FROM bans WHERE obj_id=?");
                statement.setInt(1, obj_id);
                statement.execute();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            AutoBan._log.warn("could not store bans data:" + e);
            res = false;
        }
        finally {
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        return res;
    }

    
    public static void Karma(Player actor, int karma, String msg, String GM) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            String date = new SimpleDateFormat("yy.MM.dd H:mm:ss").format(new Date());
            msg = "Add karma(" + karma + ") " + msg;
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO bans (account_name, obj_id, baned, reason, GM) VALUES(?,?,?,?,?)");
            statement.setString(1, actor.getAccountName());
            statement.setInt(2, actor.getObjectId());
            statement.setString(3, date);
            statement.setString(4, msg);
            statement.setString(5, GM);
            statement.execute();
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        catch (Exception e) {
            _log.warn("could not store bans data:" + e);
        }
        finally {
            DbUtils.closeQuietly(con, statement);
        }
    }

    public static void Banned(Player actor, int period, String msg) {
        AutoBan.Banned(actor, period, msg, "AutoBan");
    }

    
    public static boolean ChatBan(String actor, int period, String msg, String GM) {
        boolean res = true;
        long NoChannel = period * 60000;
        int obj_id = CharacterDAO.getInstance().getObjectIdByName(actor);
        if (obj_id == 0) {
            return false;
        }
        Player plyr = World.getPlayer(actor);
        Connection con = null;
        PreparedStatement statement = null;
        if (plyr != null) {
            plyr.sendMessage(new CustomMessage("l2s.Util.AutoBan.ChatBan").addString(GM).addNumber(period));
            plyr.updateNoChannel(NoChannel);
            return res;
        }
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET nochannel = ? WHERE obj_Id=?");
            statement.setLong(1, NoChannel > 0L ? NoChannel / 1000L : NoChannel);
            statement.setInt(2, obj_id);
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                res = false;
                _log.warn("Could not activate nochannel:" + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return res;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return res;
    }

    
    public static boolean ChatUnBan(String actor, String GM) {
        boolean res = true;
        Player plyr = World.getPlayer(actor);
        int obj_id = CharacterDAO.getInstance().getObjectIdByName(actor);
        if (obj_id == 0) {
            return false;
        }
        Connection con = null;
        PreparedStatement statement = null;
        if (plyr != null) {
            plyr.sendMessage(new CustomMessage("l2s.Util.AutoBan.ChatUnBan").addString(GM));
            plyr.updateNoChannel(0L);
            return res;
        }
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET nochannel = ? WHERE obj_Id=?");
            statement.setLong(1, 0L);
            statement.setInt(2, obj_id);
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                res = false;
                _log.warn("Could not activate nochannel:" + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return res;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return res;
    }
}

