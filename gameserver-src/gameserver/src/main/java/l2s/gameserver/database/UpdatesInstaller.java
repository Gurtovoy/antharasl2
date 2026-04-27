/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  l2s.commons.dbutils.ScriptRunner
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.database;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.Reader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.dbutils.ScriptRunner;
import l2s.gameserver.Config;
import l2s.gameserver.database.DatabaseFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UpdatesInstaller {
    private static final Logger _log = LoggerFactory.getLogger(UpdatesInstaller.class);

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void checkAndInstall() {
        if (!Config.DATABASE_AUTOUPDATE) {
            _log.info("UpdatesInstaller: Disabled.");
            return;
        }
        _log.info("UpdatesInstaller: Checking new updates...");
        ArrayList<String> installedUpdates = new ArrayList<String>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT file_name FROM installed_updates");
            rset = statement.executeQuery();
            while (rset.next()) {
                installedUpdates.add(rset.getString("file_name").trim().toLowerCase());
            }
        }
        catch (Exception e) {
            try {
                _log.error("UpdatesInstaller: Error while restore installed updates from database: " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            return;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        File updatesDir = new File(Config.DATAPACK_ROOT, "sql/updates/");
        if (updatesDir == null || !updatesDir.isDirectory()) {
            _log.warn("UpdatesInstaller: Cannot find " + Config.DATAPACK_ROOT.getPath() + "/sql/updates/ directory!");
            return;
        }
        Object[] updateFiles = updatesDir.listFiles(new UpdateFilenameFilter());
        Arrays.sort(updateFiles);
        boolean newUpdatesInstalled = false;
        for (Object f : updateFiles) {
            String name = ((File)f).getName().trim().toLowerCase().replaceAll("^\\s*(.*?)\\s*\\.sql$", "$1");
            if (installedUpdates.stream().anyMatch(str -> str.equalsIgnoreCase(name))) continue;
            _log.info("UpdatesInstaller: Installing update: " + name + "...");
            try {
                con = DatabaseFactory.getInstance().getConnection();
                new ScriptRunner(con, false, true).runScript((Reader)new BufferedReader(new FileReader((File)f)));
                newUpdatesInstalled = true;
                statement = con.prepareStatement("REPLACE INTO installed_updates (file_name) VALUES(?)");
                statement.setString(1, name);
                statement.execute();
                DbUtils.closeQuietly((Statement)statement);
            }
            catch (Exception e) {
                _log.error("UpdatesInstaller: Error while install database update [" + name + "]: " + e, (Throwable)e);
                return;
            }
            finally {
                DbUtils.closeQuietly((Connection)con);
                _log.info("UpdatesInstaller: Installed update: " + name);
            }
        }
        if (!newUpdatesInstalled) {
            _log.info("UpdatesInstaller: No new updates.");
        } else {
            _log.info("UpdatesInstaller: All new updates installed.");
        }
    }

    private static class UpdateFilenameFilter
    implements FilenameFilter {
        private UpdateFilenameFilter() {
        }

        @Override
        public boolean accept(File dir, String name) {
            return name.matches(".+\\.sql");
        }
    }
}

