/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.pledge;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import l2s.commons.dao.JdbcEntity;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.pledge.Clan;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PledgeHuntingProgress
implements JdbcEntity {
    private static final Logger _log = LoggerFactory.getLogger(PledgeHuntingProgress.class);
    private JdbcEntityState _jdbcEntityState = JdbcEntityState.CREATED;
    private final Clan _clan;
    private int _value = 0;

    public PledgeHuntingProgress(Clan clan) {
        this._clan = clan;
    }

    public void setValue(int value) {
        this._value = value;
    }

    public int getValue() {
        return this._value;
    }

    public void setJdbcState(JdbcEntityState state) {
        this._jdbcEntityState = state;
    }

    public JdbcEntityState getJdbcState() {
        return this._jdbcEntityState;
    }

    
    public void update() {
        if (!this.getJdbcState().isUpdatable()) {
            return;
        }
        int clanId = this._clan.getClanId();
        if (clanId == 0) {
            _log.warn("HuntingProgress#update() with empty ClanId");
            Thread.dumpStack();
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET hunting_progress=? WHERE clan_id=?");
            statement.setInt(1, this.getValue());
            statement.setInt(2, clanId);
            statement.execute();
            this.setJdbcState(JdbcEntityState.STORED);
        }
        catch (Exception e) {
            try {
                _log.error("HuntingProgress#update(): ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public void save() {
        this.update();
    }

    public void delete() {
        this.update();
    }
}

