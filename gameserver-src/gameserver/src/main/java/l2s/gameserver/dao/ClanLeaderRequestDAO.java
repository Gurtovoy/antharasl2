package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.dao.ClanHallDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.pledge.ClanChangeLeaderRequest;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ClanLeaderRequestDAO {
    private static final Logger _log = LoggerFactory.getLogger(ClanHallDAO.class);
    private static final ClanLeaderRequestDAO _instance = new ClanLeaderRequestDAO();
    private static final String SELECT_SQL = "SELECT * FROM clan_leader_request";
    private static final String INSERT_SQL = "INSERT INTO  clan_leader_request(clan_id, new_leader_id, time) VALUES (?,?,?)";
    private static final String DELETE_SQL = "DELETE  FROM clan_leader_request WHERE clan_id=?";

    public static ClanLeaderRequestDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public IntObjectMap<ClanChangeLeaderRequest> select() {
        HashIntObjectMap requestList = new HashIntObjectMap();
        Connection con = null;
        Statement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.createStatement();
            rset = statement.executeQuery(SELECT_SQL);
            while (rset.next()) {
                int clanId = rset.getInt("clan_id");
                requestList.put(clanId, new ClanChangeLeaderRequest(clanId, rset.getInt("new_leader_id"), rset.getLong("time") * 1000L));
            }
        }
        catch (Exception e) {
            try {
                _log.error("ClanLeaderRequestDAO.select(): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return requestList;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void delete(ClanChangeLeaderRequest changeLeaderRequest) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_SQL);
            statement.setInt(1, changeLeaderRequest.getClanId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("ClanLeaderRequestDAO.delete(ClanChangeLeaderRequest): " + e, (Throwable)e);
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
    public void insert(ClanChangeLeaderRequest request) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(INSERT_SQL);
            statement.setInt(1, request.getClanId());
            statement.setInt(2, request.getNewLeaderId());
            statement.setLong(3, request.getTime() / 1000L);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("ClanLeaderRequestDAO.insert(ClanChangeLeaderRequest): " + e, (Throwable)e);
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

