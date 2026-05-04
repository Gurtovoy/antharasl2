/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.data.xml.holder.ProductDataHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ProductHistoryItem;
import l2s.gameserver.templates.item.product.ProductItem;
import org.napile.primitive.maps.IntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ProductHistoryDAO {
    private static final Logger _log = LoggerFactory.getLogger(ProductHistoryDAO.class);
    private static final ProductHistoryDAO _instance = new ProductHistoryDAO();

    public static ProductHistoryDAO getInstance() {
        return _instance;
    }

    
    public void select(Player owner, IntObjectMap<ProductHistoryItem> map) {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT product_id, purchased_count, last_purchase_time FROM product_history WHERE account_name = ?");
            statement.setString(1, owner.getAccountName());
            rset = statement.executeQuery();
            while (rset.next()) {
                int product_id = rset.getInt("product_id");
                int purchased_count = rset.getInt("purchased_count");
                int last_purchase_time = rset.getInt("last_purchase_time");
                ProductItem product = ProductDataHolder.getInstance().getProduct(product_id);
                if (product == null) continue;
                map.put(product_id, new ProductHistoryItem(product, purchased_count, last_purchase_time));
            }
        }
        catch (Exception e) {
            try {
                _log.error("ProductHistoryDAO.select(Player): " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    
    public boolean replace(Player owner, ProductHistoryItem item) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO product_history (account_name,product_id,purchased_count,last_purchase_time) VALUES(?,?,?,?)");
            statement.setString(1, owner.getAccountName());
            statement.setInt(2, item.getProduct().getId());
            statement.setInt(3, item.getPurchasedCount());
            statement.setInt(4, item.getLastPurchaseTime());
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn(owner.getBlockList() + " could not add item to premium item list: " + item, (Throwable)e);
                bl = false;
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return bl;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return true;
    }

    
    public boolean delete(Player owner, int productId) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM product_history WHERE account_name=? AND product_id=?");
            statement.setString(1, owner.getAccountName());
            statement.setInt(2, productId);
            statement.execute();
        }
        catch (Exception e) {
            boolean bl;
            try {
                _log.warn(owner.getBlockList() + " could not delete item from premium item list : ID[" + productId + "]", (Throwable)e);
                bl = false;
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return bl;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return true;
    }
}

