package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.entity.residence.clanhall.InstantClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.tables.ClanTable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class InstantClanHallDAO {
    private static final Logger _log = LoggerFactory.getLogger(InstantClanHallDAO.class);
    private static final InstantClanHallDAO _instance = new InstantClanHallDAO();
    private static final String SELECT_INFO_SQL_QUERY = "SELECT * FROM instant_clanhall_info WHERE id = ?";
    private static final String REPLACE_INFO_SQL_QUERY = "REPLACE INTO instant_clanhall_info (id,siege_date) VALUES (?,?)";
    private static final String SELECT_OWNER_SQL_QUERY = "SELECT owner_id FROM instant_clanhall_owners WHERE id = ?";
    private static final String REPLACE_OWNER_SQL_QUERY = "REPLACE INTO instant_clanhall_owners (owner_id,id) VALUES (?,?)";
    private static final String DELETE_OWNER_SQL_QUERY = "DELETE FROM instant_clanhall_owners WHERE owner_id=? AND id=?";

    public static InstantClanHallDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void select(InstantClanHall clanHall) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block5: {
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement(SELECT_OWNER_SQL_QUERY);
                statement.setInt(1, clanHall.getInstantId());
                rset = statement.executeQuery();
                while (rset.next()) {
                    clanHall.addOwner(ClanTable.getInstance().getClan(rset.getInt("owner_id")), false);
                }
                DbUtils.closeQuietly((Statement)statement, (ResultSet)rset);
                statement = con.prepareStatement(SELECT_INFO_SQL_QUERY);
                statement.setInt(1, clanHall.getInstantId());
                rset = statement.executeQuery();
                if (!rset.next()) break block5;
                clanHall.getSiegeDate().setTimeInMillis((long)rset.getInt("siege_date") * 1000L);
            }
            catch (Exception e) {
                try {
                    _log.error("InstantClanHallDAO.select(InstantClanHall):" + e, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public void update(InstantClanHall clanHall) {
        if (!clanHall.getJdbcState().isUpdatable()) {
            return;
        }
        clanHall.setJdbcState(JdbcEntityState.STORED);
        this.update0(clanHall);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void update0(InstantClanHall clanHall) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(REPLACE_INFO_SQL_QUERY);
            statement.setInt(1, clanHall.getInstantId());
            statement.setInt(2, (int)(clanHall.getSiegeDate().getTimeInMillis() / 1000L));
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("InstantClanHallDAO#update0(InstantClanHall): " + e, (Throwable)e);
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
    public boolean insert(InstantClanHall clanHall, Clan owner) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(REPLACE_OWNER_SQL_QUERY);
            statement.setInt(1, owner.getClanId());
            statement.setInt(2, clanHall.getInstantId());
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn("InstantClanHallDAO.insert(InstantClanHall,Clan): " + e, (Throwable)e);
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

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean delete(InstantClanHall clanHall, Clan owner) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(DELETE_OWNER_SQL_QUERY);
            statement.setInt(1, owner.getClanId());
            statement.setInt(2, clanHall.getInstantId());
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn("InstantClanHallDAO.delete(InstantClanHall,Clan): " + e, (Throwable)e);
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
}

