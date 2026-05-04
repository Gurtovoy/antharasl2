package l2s.gameserver.security;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HWIDBan {
    private static final Logger _log = LoggerFactory.getLogger(HWIDBan.class);
    private static HWIDBan _instance;
    private ArrayList<String> _banList = new ArrayList();

    public static HWIDBan getInstance() {
        if (_instance == null) {
            _instance = new HWIDBan();
        }
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void load() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            String hwid = "";
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM ban_hwid");
            rset = statement.executeQuery();
            while (rset.next()) {
                hwid = rset.getString("hwid");
                if (hwid == "") continue;
                this._banList.add(hwid);
            }
        }
        catch (Exception e) {
            try {
                _log.info("not loaded?");
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                _log.info("HWIDBan: Black list (Hwid) loaded size: " + this._banList.size());
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            _log.info("HWIDBan: Black list (Hwid) loaded size: " + this._banList.size());
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        _log.info("HWIDBan: Black list (Hwid) loaded size: " + this._banList.size());
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void addToBlackList(String hwid) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO ban_hwid (hwid) VALUES(?)");
            statement.setString(1, hwid);
            statement.execute();
        }
        catch (Exception e) {
        }
        finally {
            this._banList.add(hwid);
            _log.info("HWIDBan: Adding hwid to black list(hwid) " + hwid);
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void deleteFromBlackList(String hwid) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE from ban_hwid WHERE hwid like ?");
            statement.setString(1, hwid);
            statement.execute();
        }
        catch (Exception e) {
        }
        finally {
            this._banList.remove(hwid);
            _log.info("HWIDBan: Remove hwid from black list(hwid) " + hwid);
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
    }

    public ArrayList<String> getAllBannedHwid() {
        return this._banList;
    }
}

