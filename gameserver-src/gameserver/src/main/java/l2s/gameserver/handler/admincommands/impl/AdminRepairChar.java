package l2s.gameserver.handler.admincommands.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.dao.CharacterVariablesDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.Player;

public class AdminRepairChar
implements IAdminCommandHandler {
    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Loose catch block
     */
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        int objId;
        block9: {
            ResultSet rset;
            PreparedStatement statement;
            Connection con;
            block8: {
                Commands command = (Commands)comm;
                if (activeChar.getPlayerAccess() == null || !activeChar.getPlayerAccess().CanEditChar) {
                    return false;
                }
                if (wordList.length != 2) {
                    return false;
                }
                con = null;
                statement = null;
                rset = null;
                objId = 0;
                try {
                    con = DatabaseFactory.getInstance().getConnection();
                    statement = con.prepareStatement("UPDATE characters SET x=-84318, y=244579, z=-3730 WHERE char_name=?");
                    statement.setString(1, wordList[1]);
                    statement.execute();
                    DbUtils.close((Statement)statement);
                    statement = con.prepareStatement("SELECT obj_id FROM characters where char_name=?");
                    statement.setString(1, wordList[1]);
                    rset = statement.executeQuery();
                    if (rset.next()) {
                        objId = rset.getInt(1);
                    }
                    DbUtils.close((Statement)statement, (ResultSet)rset);
                } catch (java.sql.SQLException e) {
                    e.printStackTrace();
                    DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
                    return false;
                }
                if (objId != 0) break block8;
                boolean bl = false;
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
                return bl;
            }
            try {
                statement = con.prepareStatement("DELETE FROM character_shortcuts WHERE object_id=?");
                statement.setInt(1, objId);
                statement.execute();
                DbUtils.close((Statement)statement);
                statement = con.prepareStatement("UPDATE items SET loc='INVENTORY' WHERE owner_id=? AND loc!='WAREHOUSE'");
                statement.setInt(1, objId);
                statement.execute();
                DbUtils.close((Statement)statement);
            }
            catch (Exception e) {
                // exception handling
            }
            finally {
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        CharacterVariablesDAO.getInstance().delete(objId, "reflection");
        return true;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_restore,
        admin_repair;

    }
}

