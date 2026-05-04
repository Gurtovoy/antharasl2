package l2s.authserver.database;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.concurrent.TimeUnit;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import l2s.authserver.Config;

public class DatabaseFactory extends HikariDataSource {
    private static final DatabaseFactory _instance = new DatabaseFactory();

    public static DatabaseFactory getInstance() {
        return _instance;
    }

    private DatabaseFactory() {
        super(buildHikariConfig());
    }

    private static HikariConfig buildHikariConfig() {
        HikariConfig c = new HikariConfig();
        c.setPoolName("AuthServer");
        c.setDriverClassName(Config.DATABASE_DRIVER);
        c.setJdbcUrl(Config.DATABASE_URL);
        c.setUsername(Config.DATABASE_LOGIN);
        c.setPassword(Config.DATABASE_PASSWORD);
        int max = Math.max(1, Config.DATABASE_MAX_CONNECTIONS);
        c.setMaximumPoolSize(max);
        c.setMinimumIdle(Math.min(max, Math.max(1, Math.min(2, max))));
        long idleMs = Math.max(30_000L, (long) Config.DATABASE_MAX_IDLE_TIMEOUT * 1000L);
        c.setIdleTimeout(idleMs);
        c.setMaxLifetime(Math.min(Math.max(idleMs * 2L, 600_000L), 1_800_000L));
        long waitMs = Config.DATABASE_MAX_WAIT_MS;
        c.setConnectionTimeout(waitMs > 0L ? Math.max(250L, waitMs) : TimeUnit.HOURS.toMillis(8));
        c.addDataSourceProperty("cachePrepStmts", "true");
        c.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        c.addDataSourceProperty("useServerPrepStmts", "true");
        return c;
    }

    public Connection getConnection(Connection con) throws SQLException {
        if (con == null || con.isClosed()) {
            return super.getConnection();
        }
        return con;
    }

    public int getBusyConnectionCount() {
        try {
            return getHikariPoolMXBean() != null ? getHikariPoolMXBean().getActiveConnections() : 0;
        }
        catch (Exception e) {
            return 0;
        }
    }

    public int getIdleConnectionCount() {
        try {
            return getHikariPoolMXBean() != null ? getHikariPoolMXBean().getIdleConnections() : 0;
        }
        catch (Exception e) {
            return 0;
        }
    }

    public void shutdown() throws Exception {
        if (!isClosed()) {
            close();
        }
    }
}
