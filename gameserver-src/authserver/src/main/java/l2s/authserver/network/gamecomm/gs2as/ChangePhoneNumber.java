/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver.network.gamecomm.gs2as;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import l2s.authserver.database.DatabaseFactory;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ChangePhoneNumber
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(ChangePhoneNumber.class);
    private String account;
    private long phoneNumber;

    @Override
    protected boolean readImpl() {
        this.account = this.readS();
        this.phoneNumber = this.readQ();
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
            statement = con.prepareStatement("UPDATE accounts SET phone_nubmer=? WHERE login=?");
            statement.setLong(1, this.phoneNumber);
            statement.setString(2, this.account);
            statement.execute();
            statement.close();
        }
        catch (SQLException e) {
            _log.warn("ChangePhoneNumber: Could not write data. Reason: " + e);
        }
        finally {
            try {
                if (con != null) {
                    con.close();
                }
            }
            catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}

