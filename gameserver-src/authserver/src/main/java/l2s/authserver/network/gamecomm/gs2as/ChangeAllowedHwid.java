package l2s.authserver.network.gamecomm.gs2as;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import l2s.authserver.database.DatabaseFactory;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ChangeAllowedHwid
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(ChangeAllowedHwid.class);
    private String account;
    private String hwid;

    @Override
    protected boolean readImpl() {
        this.account = this.readS();
        this.hwid = this.readS();
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
            statement = con.prepareStatement("UPDATE accounts SET allow_hwid=? WHERE login=?");
            statement.setString(1, this.hwid);
            statement.setString(2, this.account);
            statement.execute();
            statement.close();
        }
        catch (SQLException e) {
            _log.warn("ChangeAllowedIP: Could not write data. Reason: " + e);
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

