/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.templates.item.product.ProductItem;

public final class ProductDataHolder
extends AbstractHolder {
    private static final ProductDataHolder _instance = new ProductDataHolder();
    private final TIntObjectMap<ProductItem> _products = new TIntObjectHashMap();

    public static ProductDataHolder getInstance() {
        return _instance;
    }

    public void addProduct(ProductItem product) {
        this._products.put(product.getId(), product);
    }

    public Collection<ProductItem> getProducts() {
        return this._products.valueCollection();
    }

    public Collection<ProductItem> getProductsOnSale(Player player) {
        ArrayList<ProductItem> products = new ArrayList<ProductItem>();
        for (ProductItem product : this.getProducts()) {
            if (!product.isOnSale() || product.getMinVipLevel() > player.getVIP().getLevel() || product.getMaxVipLevel() < player.getVIP().getLevel() || System.currentTimeMillis() < product.getStartTimeSale() || System.currentTimeMillis() > product.getEndTimeSale() || product.getLocationId() != -1 && product.getLocationId() != player.getLocationId()) continue;
            products.add(product);
        }
        return products;
    }

    public ProductItem getProduct(int id) {
        return (ProductItem)this._products.get(id);
    }

    public int size() {
        return this._products.size();
    }

    public void clear() {
        this._products.clear();
    }
}

