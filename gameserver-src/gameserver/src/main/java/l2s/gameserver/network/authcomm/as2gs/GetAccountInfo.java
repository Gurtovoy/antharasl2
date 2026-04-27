/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.napile.primitive.Containers
 *  org.napile.primitive.lists.IntList
 *  org.napile.primitive.lists.impl.ArrayIntList
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.authcomm.as2gs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.Config;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import l2s.gameserver.network.authcomm.gs2as.SetAccountInfo;
import org.napile.primitive.Containers;
import org.napile.primitive.lists.IntList;
import org.napile.primitive.lists.impl.ArrayIntList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GetAccountInfo
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(GetAccountInfo.class);
    private String _account;

    @Override
    protected boolean readImpl() {
        this._account = this.readS();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        int playerSize = 0;
        IntList deleteChars = Containers.EMPTY_INT_LIST;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT deletetime FROM characters WHERE account_name=?");
            statement.setString(1, this._account);
            rset = statement.executeQuery();
            while (rset.next()) {
                ++playerSize;
                int d = rset.getInt("deletetime");
                if (d <= 0) continue;
                if (deleteChars.isEmpty()) {
                    deleteChars = new ArrayIntList(3);
                }
                deleteChars.add(d + Config.CHARACTER_DELETE_AFTER_HOURS * 60 * 60);
            }
        }
        catch (Exception e) {
            try {
                _log.error("GetAccountInfo:runImpl():" + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        AuthServerCommunication.getInstance().sendPacket(new SetAccountInfo(this._account, playerSize, deleteChars.toArray()));
    }
}

