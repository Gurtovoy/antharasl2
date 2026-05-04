package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.dao.CastleDoorUpgradeDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.entity.residence.Residence;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CastleDamageZoneDAO {
    private static final CastleDamageZoneDAO _instance = new CastleDamageZoneDAO();
    private static final Logger _log = LoggerFactory.getLogger(CastleDoorUpgradeDAO.class);
    public static final String SELECT_SQL_QUERY = "SELECT zone FROM castle_damage_zones WHERE residence_id=?";
    public static final String INSERT_SQL_QUERY = "INSERT INTO castle_damage_zones (residence_id, zone) VALUES (?,?)";
    public static final String DELETE_SQL_QUERY = "DELETE FROM castle_damage_zones WHERE residence_id=?";

    public static CastleDamageZoneDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<String> load(Residence r) {
        List<String> set = Collections.emptyList();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(SELECT_SQL_QUERY);
            statement.setInt(1, r.getId());
            rset = statement.executeQuery();
            set = new ArrayList();
            while (rset.next()) {
                set.add(rset.getString("zone"));
            }
        }
        catch (Exception e) {
            try {
                _log.error("CastleDamageZoneDAO:load(Residence): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return set;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void insert(Residence residence, String name) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(INSERT_SQL_QUERY);
            statement.setInt(1, residence.getId());
            statement.setString(2, name);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CastleDamageZoneDAO:insert(Residence, String): " + e, (Throwable)e);
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
    public void delete(Residence residence) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.setInt(1, residence.getId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CastleDamageZoneDAO:delete(Residence): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }
}

