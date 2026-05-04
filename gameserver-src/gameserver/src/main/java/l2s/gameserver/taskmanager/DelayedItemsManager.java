package l2s.gameserver.taskmanager;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DelayedItemsManager
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(DelayedItemsManager.class);
    private static DelayedItemsManager _instance;
    private static final Object _lock;
    private int last_payment_id = 0;

    public static DelayedItemsManager getInstance() {
        if (_instance == null) {
            _instance = new DelayedItemsManager();
        }
        return _instance;
    }

    public DelayedItemsManager() {
        Connection con = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            this.last_payment_id = this.get_last_payment_id(con);
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con);
        }
        ThreadPoolManager.getInstance().schedule(this, 10000L);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private int get_last_payment_id(Connection con) {
        int result;
        ResultSet rset;
        PreparedStatement st;
        block4: {
            st = null;
            rset = null;
            result = this.last_payment_id;
            try {
                st = con.prepareStatement("SELECT MAX(payment_id) AS last FROM items_delayed");
                rset = st.executeQuery();
                if (!rset.next()) break block4;
                result = rset.getInt("last");
            }
            catch (Exception e) {
                try {
                    _log.error("", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Statement)st, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Statement)st, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Statement)st, (ResultSet)rset);
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public void run() {
        block9: {
            Player player = null;
            Connection con = null;
            PreparedStatement st = null;
            ResultSet rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                int last_payment_id_temp = this.get_last_payment_id(con);
                if (last_payment_id_temp == this.last_payment_id) break block9;
                Object object = _lock;
                synchronized (object) {
                    st = con.prepareStatement("SELECT DISTINCT owner_id FROM items_delayed WHERE payment_status=0 AND payment_id > ?");
                    st.setInt(1, this.last_payment_id);
                    rset = st.executeQuery();
                    while (rset.next()) {
                        player = GameObjectsStorage.getPlayer(rset.getInt("owner_id"));
                        if (player == null) continue;
                        this.loadDelayed(player, true);
                    }
                    this.last_payment_id = last_payment_id_temp;
                }
            }
            catch (Exception e) {
                _log.error("", (Throwable)e);
            }
            finally {
                DbUtils.closeQuietly((Connection)con, st, rset);
            }
        }
        ThreadPoolManager.getInstance().schedule(this, 10000L);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void addDelayed(int objectId, int itemId, long itemCount, int enchant, String desc) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO items_delayed (owner_id, item_id, count, enchant_level, description) VALUES (?, ?, ?, ?, ?)");
            statement.setInt(1, objectId);
            statement.setInt(2, itemId);
            statement.setLong(3, itemCount);
            statement.setInt(4, enchant);
            statement.setString(5, desc);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.info("DelayedItemsManager.addDelayed(int, int, long): " + e, (Throwable)e);
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
     * Unable to fully structure code
     */
    public int loadDelayed(Player player, boolean notify) {
        if (player == null) {
            return 0;
        }
        int player_id = player.getObjectId();
        l2s.gameserver.model.items.PcInventory inv = player.getInventory();
        if (inv == null) {
            return 0;
        }
        int restored_counter = 0;
        Connection con = null;
        PreparedStatement st = null;
        PreparedStatement st_delete = null;
        ResultSet rset = null;
        Object var10_10 = DelayedItemsManager._lock;
        synchronized (var10_10) {
            try {
                con = DatabaseFactory.getInstance().getConnection();
                st = con.prepareStatement("SELECT * FROM items_delayed WHERE owner_id=? AND payment_status=0");
                st.setInt(1, player_id);
                rset = st.executeQuery();
                st_delete = con.prepareStatement("UPDATE items_delayed SET payment_status=1 WHERE payment_id=?");
                while (rset.next()) {
                    int ITEM_ID = rset.getInt("item_id");
                    int PAYMENT_ID = rset.getInt("payment_id");
                    block16: {
                        ItemTemplate ITEM_TEMPLATE = ItemHolder.getInstance().getTemplate(ITEM_ID);
                        if (ITEM_TEMPLATE == null) break block16;
                        long ITEM_COUNT = rset.getLong("count");
                        int ITEM_ENCHANT = rset.getInt("enchant_level");
                        int FLAGS = rset.getInt("flags");
                        int ATTRIBUTE = rset.getInt("attribute");
                        int ATTRIBUTE_LEVEL = rset.getInt("attribute_level");
                        String DESCRIPTION = rset.getString("description");
                        boolean stackable = ITEM_TEMPLATE.isStackable();
                        boolean success = false;
                        int i = 0;
                        while ((long)i < (stackable != false ? 1L : ITEM_COUNT)) {
                            if (ITEM_COUNT > 0L) {
                                ItemInstance item = ItemFunctions.createItem(ITEM_ID);
                                if (item.isStackable()) {
                                    item.setCount(ITEM_COUNT);
                                } else {
                                    item.setEnchantLevel(ITEM_ENCHANT);
                                }
                                item.setLocation(ItemInstance.ItemLocation.INVENTORY);
                                item.setCustomFlags(FLAGS);
                                ItemInstance newItem = inv.addItem(item);
                                if (newItem == null) {
                                    DelayedItemsManager._log.warn("Unable to delayed create item " + ITEM_ID + " request " + PAYMENT_ID);
                                } else {
                                    if (notify) {
                                        player.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(ITEM_ID, stackable != false ? ITEM_COUNT : 1L, ITEM_ENCHANT));
                                    }
                                    Log.LogItem(player, "DelayedItemReceive", newItem, ITEM_COUNT, DESCRIPTION);
                                }
                            }
                            success = true;
                            ++restored_counter;
                            ++i;
                        }
                        if (!success) continue;
                    }
                    st_delete.setInt(1, PAYMENT_ID);
                    st_delete.execute();
                }
            }
            catch (Exception e) {
                DelayedItemsManager._log.error("Could not load delayed items for player " + player + "!", (Throwable)e);
            }
            finally {
                DbUtils.closeQuietly((Statement)st_delete);
                DbUtils.closeQuietly((Connection)con, (Statement)st, (ResultSet)rset);
            }
        }
        return restored_counter;
    }

    static {
        _lock = new Object();
    }
}

