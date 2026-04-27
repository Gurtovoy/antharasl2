/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.dbutils;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DbUtils {
    public static void close(Connection conn) throws SQLException {
        if (conn != null) {
            conn.close();
        }
    }

    public static void close(ResultSet rs) throws SQLException {
        if (rs != null) {
            rs.close();
        }
    }

    public static void close(Statement stmt) throws SQLException {
        if (stmt != null) {
            stmt.close();
        }
    }

    public static void close(Statement stmt, ResultSet rs) throws SQLException {
        DbUtils.close(stmt);
        DbUtils.close(rs);
    }

    public static void closeQuietly(Connection conn) {
        try {
            DbUtils.close(conn);
        }
        catch (SQLException sQLException) {
            // empty catch block
        }
    }

    public static void closeQuietly(Connection conn, Statement stmt) {
        try {
            DbUtils.closeQuietly(stmt);
        }
        finally {
            DbUtils.closeQuietly(conn);
        }
    }

    public static void closeQuietly(Statement stmt, ResultSet rs) {
        try {
            DbUtils.closeQuietly(stmt);
        }
        finally {
            DbUtils.closeQuietly(rs);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void closeQuietly(Connection conn, Statement stmt, ResultSet rs) {
        try {
            DbUtils.closeQuietly(rs);
        }
        finally {
            try {
                DbUtils.closeQuietly(stmt);
            }
            finally {
                DbUtils.closeQuietly(conn);
            }
        }
    }

    public static void closeQuietly(ResultSet rs) {
        try {
            DbUtils.close(rs);
        }
        catch (SQLException sQLException) {
            // empty catch block
        }
    }

    public static void closeQuietly(Statement stmt) {
        try {
            DbUtils.close(stmt);
        }
        catch (SQLException sQLException) {
            // empty catch block
        }
    }
}

