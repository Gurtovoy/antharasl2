package l2s.gameserver.model.entity.residence;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Calendar;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.templates.residence.ResidenceFunctionTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ResidenceFunction {
    private static final Logger _log = LoggerFactory.getLogger(ResidenceFunction.class);
    private final ResidenceFunctionTemplate _template;
    private final int _residenceId;
    private final Calendar _endDate = Calendar.getInstance();
    private boolean _inDebt = false;

    public ResidenceFunction(ResidenceFunctionTemplate template, int residenceId) {
        this._template = template;
        this._residenceId = residenceId;
    }

    public int getId() {
        return this._template.getId();
    }

    public ResidenceFunctionType getType() {
        return this._template.getType();
    }

    public int getLevel() {
        return this._template.getLevel();
    }

    public ResidenceFunctionTemplate getTemplate() {
        return this._template;
    }

    public int getResidenceId() {
        return this._residenceId;
    }

    public long getEndTimeInMillis() {
        return this._endDate.getTimeInMillis();
    }

    public void setEndTimeInMillis(long time) {
        this._endDate.setTimeInMillis(time);
    }

    public void setInDebt(boolean inDebt) {
        this._inDebt = inDebt;
    }

    public boolean isInDebt() {
        return this._inDebt;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void updateRentTime(boolean inDebt) {
        this.setEndTimeInMillis(System.currentTimeMillis() + 86400000L);
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE residence_functions SET end_time=?, in_debt=? WHERE residence_id=? AND type=? AND level=?");
            statement.setInt(1, (int)(this.getEndTimeInMillis() / 1000L));
            statement.setInt(2, inDebt ? 1 : 0);
            statement.setInt(3, this.getResidenceId());
            statement.setInt(4, this.getType().ordinal());
            statement.setInt(5, this.getLevel());
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.error("Cannot update rent time: ", (Throwable)e);
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

