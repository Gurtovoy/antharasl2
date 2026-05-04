package l2s.gameserver.database;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class mysql {
    private static final Logger _log = LoggerFactory.getLogger(mysql.class);

    public static boolean setEx(DatabaseFactory db, String query, Object ... vars) {
        if (db == null) {
            try {
                db = DatabaseFactory.getInstance();
            } catch (SQLException e) {
                _log.warn("Could not get database instance: " + e);
                return false;
            }
        }
        if (vars.length == 0) {
            try (Connection con = db.getConnection();
                 Statement statement = con.createStatement()) {
                statement.executeUpdate(query);
            } catch (Exception e) {
                _log.warn("Could not execute update '" + query + "': " + e);
                e.printStackTrace();
                return false;
            }
        } else {
            try (Connection con = db.getConnection();
                 PreparedStatement pstatement = con.prepareStatement(query)) {
                mysql.setVars(pstatement, vars);
                pstatement.executeUpdate();
            } catch (Exception e) {
                _log.warn("Could not execute update '" + query + "': " + e);
                e.printStackTrace();
                return false;
            }
        }
        return true;
    }

    public static void setVars(PreparedStatement statement, Object ... vars) throws SQLException {
        for (int i = 0; i < vars.length; ++i) {
            Object v = vars[i];
            int idx = i + 1;
            if (v == null) {
                statement.setObject(idx, null);
                continue;
            }
            if (v instanceof Number) {
                double double_val;
                Number n = (Number)v;
                long long_val = n.longValue();
                if ((double)long_val == (double_val = n.doubleValue())) {
                    statement.setLong(idx, long_val);
                    continue;
                }
                statement.setDouble(idx, double_val);
                continue;
            }
            if (v instanceof Boolean) {
                statement.setBoolean(idx, (Boolean)v);
                continue;
            }
            if (v instanceof String) {
                statement.setString(idx, (String)v);
                continue;
            }
            if (v instanceof byte[]) {
                statement.setBytes(idx, (byte[])v);
                continue;
            }
            if (v instanceof Timestamp) {
                statement.setTimestamp(idx, (Timestamp)v);
                continue;
            }
            if (v instanceof Date) {
                statement.setDate(idx, (Date)v);
                continue;
            }
            if (v instanceof Time) {
                statement.setTime(idx, (Time)v);
                continue;
            }
            if (v instanceof java.util.Date) {
                statement.setTimestamp(idx, new Timestamp(((java.util.Date)v).getTime()));
                continue;
            }
            throw new SQLException("mysql.setVars: unsupported type at index " + i + ": " + v.getClass().getName());
        }
    }

    public static boolean set(String query, Object ... vars) {
        return mysql.setEx(null, query, vars);
    }

    public static boolean set(String query) {
        return mysql.setEx(null, query, new Object[0]);
    }

    public static Object get(String query) {
        Object ret = null;
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             Statement statement = con.createStatement();
             ResultSet rset = statement.executeQuery(query + " LIMIT 1")) {
            ResultSetMetaData md = rset.getMetaData();
            if (rset.next()) {
                if (md.getColumnCount() > 1) {
                    HashMap<String, Object> tmp = new HashMap<String, Object>();
                    for (int i = md.getColumnCount(); i > 0; --i) {
                        tmp.put(md.getColumnName(i), rset.getObject(i));
                    }
                    ret = tmp;
                } else {
                    ret = rset.getObject(1);
                }
            }
        } catch (Exception e) {
            _log.warn("Could not execute query '" + query + "': " + e);
            e.printStackTrace();
        }
        return ret;
    }

    public static List<Map<String, Object>> getAll(String query) {
        ArrayList<Map<String, Object>> ret = new ArrayList<Map<String, Object>>();
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             Statement statement = con.createStatement();
             ResultSet rset = statement.executeQuery(query)) {
            ResultSetMetaData md = rset.getMetaData();
            while (rset.next()) {
                HashMap<String, Object> tmp = new HashMap<String, Object>();
                for (int i = md.getColumnCount(); i > 0; --i) {
                    tmp.put(md.getColumnName(i), rset.getObject(i));
                }
                ret.add(tmp);
            }
        } catch (Exception e) {
            _log.warn("Could not execute query '" + query + "': " + e);
            e.printStackTrace();
        }
        return ret;
    }

    public static List<Object> get_array(DatabaseFactory db, String query) {
        ArrayList<Object> ret = new ArrayList<Object>();
        if (db == null) {
            try {
                db = DatabaseFactory.getInstance();
            } catch (SQLException e) {
                _log.warn("Could not get database instance: " + e);
                return ret;
            }
        }
        try (Connection con = db.getConnection();
             PreparedStatement statement = con.prepareStatement(query);
             ResultSet rset = statement.executeQuery()) {
            ResultSetMetaData md = rset.getMetaData();
            while (rset.next()) {
                if (md.getColumnCount() > 1) {
                    HashMap<String, Object> tmp = new HashMap<String, Object>();
                    for (int i = 0; i < md.getColumnCount(); ++i) {
                        tmp.put(md.getColumnName(i + 1), rset.getObject(i + 1));
                    }
                    ret.add(tmp);
                    continue;
                }
                ret.add(rset.getObject(1));
            }
        } catch (Exception e) {
            _log.warn("Could not execute query '" + query + "': " + e);
            e.printStackTrace();
        }
        return ret;
    }

    public static List<Object> get_array(String query) {
        return mysql.get_array(null, query);
    }

    public static int simple_get_int(String ret_field, String table, String where) {
        String query = "SELECT " + ret_field + " FROM `" + table + "` WHERE " + where + " LIMIT 1;";
        int res = 0;
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement statement = con.prepareStatement(query);
             ResultSet rset = statement.executeQuery()) {
            if (rset.next()) {
                res = rset.getInt(1);
            }
        } catch (Exception e) {
            _log.warn("mSGI: Error in query '" + query + "':" + e);
            e.printStackTrace();
        }
        return res;
    }

    public static int simple_get_int_alt(String ret_field, String table, String where, String where2) {
        String query = "SELECT " + ret_field + " FROM `" + table + "` WHERE " + where + " AND " + where2 + " LIMIT 1;";
        int res = 0;
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement statement = con.prepareStatement(query);
             ResultSet rset = statement.executeQuery()) {
            if (rset.next()) {
                res = rset.getInt(1);
            }
        } catch (Exception e) {
            _log.warn("mSGI: Error in query '" + query + "':" + e);
            e.printStackTrace();
        }
        return res;
    }

    public static Integer[][] simple_get_int_array(DatabaseFactory db, String[] ret_fields, String table, String where) {
        String fields = null;
        for (String field : ret_fields) {
            if (fields != null) {
                fields = fields + ",";
                fields = fields + "`" + field + "`";
                continue;
            }
            fields = "`" + field + "`";
        }
        String query = "SELECT " + fields + " FROM `" + table + "` WHERE " + where;
        if (db == null) {
            try {
                db = DatabaseFactory.getInstance();
            } catch (SQLException e) {
                _log.warn("Could not get database instance: " + e);
                return null;
            }
        }
        Integer[][] res = null;
        try (Connection con = db.getConnection();
             PreparedStatement statement = con.prepareStatement(query);
             ResultSet rset = statement.executeQuery()) {
            ArrayList<Integer[]> al = new ArrayList<Integer[]>();
            int row = 0;
            while (rset.next()) {
                Integer[] tmp = new Integer[ret_fields.length];
                for (int i = 0; i < ret_fields.length; ++i) {
                    tmp[i] = rset.getInt(i + 1);
                }
                al.add(row, tmp);
                ++row;
            }
            res = (Integer[][])al.toArray(new Integer[row][ret_fields.length]);
        } catch (Exception e) {
            _log.warn("mSGIA: Error in query '" + query + "':" + e);
            e.printStackTrace();
        }
        return res;
    }

    public static Integer[][] simple_get_int_array(String[] ret_fields, String table, String where) {
        return mysql.simple_get_int_array(null, ret_fields, table, where);
    }
}
