/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver.network.gamecomm.gs2as;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import l2s.authserver.database.DatabaseFactory;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.commons.dbutils.DbUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LockAccountIP
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(LockAccountIP.class);
    String _accname;
    String _IP;
    int _time;

    @Override
    protected boolean readImpl() {
        this._accname = this.readS();
        this._IP = this.readS();
        this._time = this.readD();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE accounts SET allow_ip = ?, lock_expire = ? WHERE login = ?");
            statement.setString(1, this._IP);
            statement.setInt(2, this._time);
            statement.setString(3, this._accname);
            statement.executeUpdate();
            DbUtils.closeQuietly((Statement)statement);
        }
        catch (Exception e) {
            _log.error("Failed to lock/unlock account: " + e.getMessage());
        }
        finally {
            DbUtils.closeQuietly((Connection)con);
        }
    }
}

