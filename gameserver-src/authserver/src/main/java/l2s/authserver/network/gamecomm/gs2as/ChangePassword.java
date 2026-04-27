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
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.authserver.Config;
import l2s.authserver.database.DatabaseFactory;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.authserver.network.gamecomm.as2gs.ChangePasswordResponse;
import l2s.commons.dbutils.DbUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ChangePassword
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(ChangePassword.class);
    public String _accname;
    public String _oldPass;
    public String _newPass;
    public String _hwid;

    @Override
    protected boolean readImpl() {
        this._accname = this.readS();
        this._oldPass = this.readS();
        this._newPass = this.readS();
        this._hwid = this.readS();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        String dbPassword = null;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rs = null;
        try {
            block16: {
                con = DatabaseFactory.getInstance().getConnection();
                try {
                    statement = con.prepareStatement("SELECT * FROM accounts WHERE login = ?");
                    statement.setString(1, this._accname);
                    rs = statement.executeQuery();
                    if (!rs.next()) break block16;
                    dbPassword = rs.getString("password");
                }
                catch (Exception e) {
                    try {
                        _log.warn("Can't recive old password for account " + this._accname + ", exciption :" + e);
                    }
                    catch (Throwable throwable) {
                        DbUtils.closeQuietly((Statement)statement, rs);
                        throw throwable;
                    }
                    DbUtils.closeQuietly((Statement)statement, (ResultSet)rs);
                }
            }
            DbUtils.closeQuietly((Statement)statement, (ResultSet)rs);
            try {
                if (!Config.DEFAULT_CRYPT.compare(this._oldPass, dbPassword)) {
                    ChangePasswordResponse cp1 = new ChangePasswordResponse(this._accname, false);
                    this.sendPacket(cp1);
                } else {
                    statement = con.prepareStatement("UPDATE accounts SET password = ? WHERE login = ?");
                    statement.setString(1, Config.DEFAULT_CRYPT.encrypt(this._newPass));
                    statement.setString(2, this._accname);
                    int result = statement.executeUpdate();
                    ChangePasswordResponse cp1 = new ChangePasswordResponse(this._accname, result != 0);
                    this.sendPacket(cp1);
                }
            }
            catch (Exception e1) {
                e1.printStackTrace();
            }
            finally {
                DbUtils.closeQuietly((Statement)statement);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            DbUtils.closeQuietly((Connection)con);
        }
    }
}

