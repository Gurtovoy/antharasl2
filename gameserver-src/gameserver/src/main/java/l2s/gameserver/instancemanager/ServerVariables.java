/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.instancemanager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.templates.StatsSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ServerVariables {
    private static final Logger _log = LoggerFactory.getLogger(ServerVariables.class);
    private static StatsSet server_vars = null;

    private static StatsSet getVars() {
        if (server_vars == null) {
            server_vars = new StatsSet();
            ServerVariables.LoadFromDB();
        }
        return server_vars;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static void LoadFromDB() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM server_variables");
            rs = statement.executeQuery();
            while (rs.next()) {
                server_vars.set(rs.getString("name"), rs.getString("value"));
            }
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rs);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rs);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rs);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static void SaveToDB(String name) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            String value = ServerVariables.getVars().getString(name, "");
            if (value.isEmpty()) {
                statement = con.prepareStatement("DELETE FROM server_variables WHERE name = ?");
                statement.setString(1, name);
                statement.execute();
            } else {
                statement = con.prepareStatement("REPLACE INTO server_variables (name, value) VALUES (?,?)");
                statement.setString(1, name);
                statement.setString(2, value);
                statement.execute();
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, statement);
        }
    }

    public static boolean getBool(String name) {
        return ServerVariables.getVars().getBool(name);
    }

    public static boolean getBool(String name, boolean defult) {
        return ServerVariables.getVars().getBool(name, defult);
    }

    public static int getInt(String name) {
        return ServerVariables.getVars().getInteger(name);
    }

    public static int getInt(String name, int defult) {
        return ServerVariables.getVars().getInteger(name, defult);
    }

    public static long getLong(String name) {
        return ServerVariables.getVars().getLong(name);
    }

    public static long getLong(String name, long defult) {
        return ServerVariables.getVars().getLong(name, defult);
    }

    public static double getFloat(String name) {
        return ServerVariables.getVars().getDouble(name);
    }

    public static double getFloat(String name, double defult) {
        return ServerVariables.getVars().getDouble(name, defult);
    }

    public static String getString(String name) {
        return ServerVariables.getVars().getString(name);
    }

    public static String getString(String name, String defult) {
        return ServerVariables.getVars().getString(name, defult);
    }

    public static void set(String name, boolean value) {
        ServerVariables.getVars().set(name, value);
        ServerVariables.SaveToDB(name);
    }

    public static void set(String name, int value) {
        ServerVariables.getVars().set(name, value);
        ServerVariables.SaveToDB(name);
    }

    public static void set(String name, long value) {
        ServerVariables.getVars().set(name, value);
        ServerVariables.SaveToDB(name);
    }

    public static void set(String name, double value) {
        ServerVariables.getVars().set(name, value);
        ServerVariables.SaveToDB(name);
    }

    public static void set(String name, String value) {
        ServerVariables.getVars().set(name, value);
        ServerVariables.SaveToDB(name);
    }

    public static void unset(String name) {
        ServerVariables.getVars().unset(name);
        ServerVariables.SaveToDB(name);
    }
}

