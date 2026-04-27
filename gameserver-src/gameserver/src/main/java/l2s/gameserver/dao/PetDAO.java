/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PetDAO {
    private static final Logger _log = LoggerFactory.getLogger(PetDAO.class);
    private static final PetDAO _instance = new PetDAO();
    public static final String SELECT_SQL_QUERY = "SELECT objId FROM pets WHERE item_obj_id=?";
    public static final String DELETE_SQL_QUERY = "DELETE FROM pets WHERE item_obj_id=?";

    public static PetDAO getInstance() {
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void deletePet(ItemInstance item, Creature owner) {
        int petObjectId = 0;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            int itemObjId = item.getObjectId();
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(SELECT_SQL_QUERY);
            statement.setInt(1, itemObjId);
            rset = statement.executeQuery();
            while (rset.next()) {
                petObjectId = rset.getInt("objId");
            }
            DbUtils.close((Statement)statement, (ResultSet)rset);
            Player player = owner.getPlayer();
            PetInstance pet = player.getPet();
            if (pet != null && pet.getObjectId() == petObjectId) {
                pet.unSummon(false);
            }
            if (player != null && player.isMounted() && player.getMountControlItemObjId() == itemObjId) {
                player.getMount().onControlItemDelete();
            }
            statement = con.prepareStatement(DELETE_SQL_QUERY);
            statement.setInt(1, itemObjId);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("CharNameTable.deletePet(ItemInstance, Creature): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }
}

