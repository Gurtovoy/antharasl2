/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.dao;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import l2s.commons.dao.JdbcDAO;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dao.JdbcEntityStats;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.items.ItemInstance;
import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ItemsDAO
implements JdbcDAO<Integer, ItemInstance> {
    private static final Logger _log = LoggerFactory.getLogger(ItemsDAO.class);
    private static final String RESTORE_ITEM = "SELECT object_id, owner_id, item_id, count, enchant_level, loc, loc_data, custom_type1, custom_type2, life_time, custom_flags, variation_stone_id, variation1_id, variation2_id, agathion_energy, appearance_stone_id, visual_id FROM items WHERE object_id = ?";
    private static final String RESTORE_OWNER_ITEMS = "SELECT object_id FROM items WHERE owner_id = ? AND loc = ?";
    private static final String STORE_ITEM = "INSERT INTO items (object_id, owner_id, item_id, count, enchant_level, loc, loc_data, custom_type1, custom_type2, life_time, custom_flags, variation_stone_id, variation1_id, variation2_id, agathion_energy, appearance_stone_id, visual_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    private static final String UPDATE_ITEM = "UPDATE items SET owner_id = ?, item_id = ?, count = ?, enchant_level = ?, loc = ?, loc_data = ?, custom_type1 = ?, custom_type2 = ?, life_time = ?, custom_flags = ?, variation_stone_id = ?, variation1_id = ?, variation2_id = ?, agathion_energy=?, appearance_stone_id=?, visual_id=? WHERE object_id = ?";
    private static final String REMOVE_ITEM = "DELETE FROM items WHERE object_id = ?";
    private static final String INSERT_GLOBAL_REMOVE_ITEM = "REPLACE INTO items_to_delete (item_id,description) VALUES (?,?)";
    private static final ItemsDAO instance = new ItemsDAO();
    private AtomicLong load = new AtomicLong();
    private AtomicLong insert = new AtomicLong();
    private AtomicLong update = new AtomicLong();
    private AtomicLong delete = new AtomicLong();
    private final Cache cache;
    private final JdbcEntityStats stats = new JdbcEntityStats(){

        public long getLoadCount() {
            return ItemsDAO.this.load.get();
        }

        public long getInsertCount() {
            return ItemsDAO.this.insert.get();
        }

        public long getUpdateCount() {
            return ItemsDAO.this.update.get();
        }

        public long getDeleteCount() {
            return ItemsDAO.this.delete.get();
        }
    };

    public static final ItemsDAO getInstance() {
        return instance;
    }

    private ItemsDAO() {
        this.cache = CacheManager.getInstance().getCache(ItemInstance.class.getName());
    }

    public Cache getCache() {
        return this.cache;
    }

    public JdbcEntityStats getStats() {
        return this.stats;
    }

    
    private ItemInstance load0(int objectId) throws SQLException {
        ItemInstance item = null;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(RESTORE_ITEM);
            statement.setInt(1, objectId);
            rset = statement.executeQuery();
            item = this.load0(rset);
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement, rset);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        this.load.incrementAndGet();
        return item;
    }

    private ItemInstance load0(ResultSet rset) throws SQLException {
        ItemInstance item = null;
        if (rset.next()) {
            int objectId = rset.getInt(1);
            item = new ItemInstance(objectId);
            item.setOwnerId(rset.getInt(2));
            item.setItemId(rset.getInt(3));
            item.setCount(rset.getLong(4));
            item.setEnchantLevel(rset.getInt(5));
            item.setLocName(rset.getString(6));
            item.setLocData(rset.getInt(7));
            item.setCustomType1(rset.getInt(8));
            item.setCustomType2(rset.getInt(9));
            item.setLifeTime(rset.getInt(10));
            item.setCustomFlags(rset.getInt(11));
            item.setVariationStoneId(rset.getInt(12));
            item.setVariation1Id(rset.getInt(13));
            item.setVariation2Id(rset.getInt(14));
            item.setAgathionEnergy(rset.getInt(15));
            item.setAppearanceStoneId(rset.getInt(16));
            item.setVisualId(rset.getInt(17));
            item.restoreEnsoul();
        }
        return item;
    }

    private void save0(ItemInstance item, PreparedStatement statement) throws SQLException {
        statement.setInt(1, item.getObjectId());
        statement.setInt(2, item.getOwnerId());
        statement.setInt(3, item.getItemId());
        statement.setLong(4, item.getCount());
        statement.setInt(5, item.getEnchantLevel());
        statement.setString(6, item.getLocName());
        statement.setInt(7, item.getLocData());
        statement.setInt(8, item.getCustomType1());
        statement.setInt(9, item.getCustomType2());
        statement.setInt(10, item.getLifeTime());
        statement.setInt(11, item.getCustomFlags());
        statement.setInt(12, item.getVariationStoneId());
        statement.setInt(13, item.getVariation1Id());
        statement.setInt(14, item.getVariation2Id());
        statement.setInt(15, item.getAgathionEnergy());
        statement.setInt(16, item.getAppearanceStoneId());
        statement.setInt(17, item.getVisualId());
    }

    
    private void save0(ItemInstance item) throws SQLException {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(STORE_ITEM);
            this.save0(item, statement);
            statement.execute();
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this.insert.incrementAndGet();
    }

    private void delete0(ItemInstance item, PreparedStatement statement) throws SQLException {
        statement.setInt(1, item.getObjectId());
    }

    
    private void delete0(ItemInstance item) throws SQLException {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(REMOVE_ITEM);
            this.delete0(item, statement);
            statement.execute();
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this.delete.incrementAndGet();
    }

    private void update0(ItemInstance item, PreparedStatement statement) throws SQLException {
        statement.setInt(1, item.getOwnerId());
        statement.setInt(2, item.getItemId());
        statement.setLong(3, item.getCount());
        statement.setInt(4, item.getEnchantLevel());
        statement.setString(5, item.getLocName());
        statement.setInt(6, item.getLocData());
        statement.setInt(7, item.getCustomType1());
        statement.setInt(8, item.getCustomType2());
        statement.setInt(9, item.getLifeTime());
        statement.setInt(10, item.getCustomFlags());
        statement.setInt(11, item.getVariationStoneId());
        statement.setInt(12, item.getVariation1Id());
        statement.setInt(13, item.getVariation2Id());
        statement.setInt(14, item.getAgathionEnergy());
        statement.setInt(15, item.getAppearanceStoneId());
        statement.setInt(16, item.getVisualId());
        statement.setInt(17, item.getObjectId());
    }

    
    private void update0(ItemInstance item) throws SQLException {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(UPDATE_ITEM);
            this.update0(item, statement);
            statement.execute();
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this.update.incrementAndGet();
    }

    public ItemInstance load(Integer objectId) {
        ItemInstance item;
        Element ce = this.cache.get((Serializable)objectId);
        if (ce != null) {
            ItemInstance item2 = (ItemInstance)ce.getObjectValue();
            return item2;
        }
        try {
            item = this.load0(objectId);
            if (item == null) {
                return null;
            }
            item.setJdbcState(JdbcEntityState.STORED);
        }
        catch (SQLException e) {
            _log.error("Error while restoring item : " + objectId, (Throwable)e);
            return null;
        }
        this.cache.put(new Element((Serializable)Integer.valueOf(item.getObjectId()), (Serializable)((Object)item)));
        return item;
    }

    public Collection<ItemInstance> load(Collection<Integer> objectIds) {
        List<ItemInstance> list = Collections.emptyList();
        if (objectIds.isEmpty()) {
            return list;
        }
        list = new ArrayList<ItemInstance>(objectIds.size());
        for (Integer objectId : objectIds) {
            ItemInstance item = this.load(objectId);
            if (item == null) continue;
            list.add(item);
        }
        return list;
    }

    public void save(ItemInstance item) {
        if (!item.getJdbcState().isSavable()) {
            return;
        }
        try {
            this.save0(item);
            item.setJdbcState(JdbcEntityState.STORED);
        }
        catch (SQLException e) {
            _log.error("Error while saving item : " + item, (Throwable)e);
            return;
        }
        this.cache.put(new Element((Serializable)Integer.valueOf(item.getObjectId()), (Serializable)((Object)item)));
    }

    public void save(Collection<ItemInstance> items) {
        if (items.isEmpty()) {
            return;
        }
        for (ItemInstance item : items) {
            this.save(item);
        }
    }

    public void update(ItemInstance item) {
        if (!item.getJdbcState().isUpdatable()) {
            return;
        }
        try {
            this.update0(item);
            item.setJdbcState(JdbcEntityState.STORED);
        }
        catch (SQLException e) {
            _log.error("Error while updating item : " + item, (Throwable)e);
            return;
        }
        this.cache.putIfAbsent(new Element((Serializable)Integer.valueOf(item.getObjectId()), (Serializable)((Object)item)));
    }

    public void update(Collection<ItemInstance> items) {
        if (items.isEmpty()) {
            return;
        }
        for (ItemInstance item : items) {
            this.update(item);
        }
    }

    public void saveOrUpdate(ItemInstance item) {
        if (item.getJdbcState().isSavable()) {
            this.save(item);
        } else if (item.getJdbcState().isUpdatable()) {
            this.update(item);
        }
    }

    public void saveOrUpdate(Collection<ItemInstance> items) {
        if (items.isEmpty()) {
            return;
        }
        for (ItemInstance item : items) {
            this.saveOrUpdate(item);
        }
    }

    public void delete(ItemInstance item) {
        if (!item.getJdbcState().isDeletable()) {
            return;
        }
        try {
            this.delete0(item);
            item.setJdbcState(JdbcEntityState.DELETED);
        }
        catch (SQLException e) {
            _log.error("Error while deleting item : " + item, (Throwable)e);
            return;
        }
        this.cache.remove((Serializable)Integer.valueOf(item.getObjectId()));
    }

    public void delete(Collection<ItemInstance> items) {
        if (items.isEmpty()) {
            return;
        }
        for (ItemInstance item : items) {
            this.delete(item);
        }
    }

    
    public Collection<ItemInstance> getItemsByOwnerIdAndLoc(int ownerId, ItemInstance.ItemLocation loc) {
        List<Integer> objectIds = Collections.emptyList();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(RESTORE_OWNER_ITEMS);
            statement.setInt(1, ownerId);
            statement.setString(2, loc.name());
            rset = statement.executeQuery();
            objectIds = new ArrayList();
            while (rset.next()) {
                objectIds.add(rset.getInt(1));
            }
        }
        catch (SQLException e) {
            try {
                _log.error("Error while restore items of owner : " + ownerId, (Throwable)e);
                objectIds.clear();
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return this.load(objectIds);
    }

    
    public void glovalRemoveItem(int itemId, String description) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement(INSERT_GLOBAL_REMOVE_ITEM);
            statement.setInt(1, itemId);
            statement.setString(2, description);
            statement.execute();
        }
        catch (SQLException e) {
            try {
                _log.error("Error while global remove item: " + itemId + "(" + description + ")", (Throwable)e);
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

