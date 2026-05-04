package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.data.xml.holder.ProductDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.product.ProductItem;
import l2s.gameserver.templates.item.product.ProductItemComponent;
import l2s.gameserver.utils.ItemFunctions;

public class ReciveVipProductList
extends L2GameServerPacket {
    private final long _adena;
    private final long _silverCoins;
    private final long _goldCoins;
    private final List<ProductItem> _products = new ArrayList<ProductItem>();

    public ReciveVipProductList(Player player) {
        this._adena = player.getAdena();
        this._silverCoins = ItemFunctions.getItemCount(player, 29983);
        this._goldCoins = ItemFunctions.getItemCount(player, 29984);
        this._products.addAll(ProductDataHolder.getInstance().getProductsOnSale(player));
        Collections.sort(this._products);
    }

    @Override
    protected void writeImpl() {
        this.writeQ(this._adena);
        this.writeQ(this._goldCoins);
        this.writeQ(this._silverCoins);
        this.writeC(1);
        this.writeD(this._products.size());
        for (ProductItem product : this._products) {
            this.writeD(product.getId());
            this.writeC(product.getCategory());
            this.writeC(product.getCategory() == 15 ? 3 : 0);
            this.writeD(product.getCategory() == 15 ? product.getGoldCoinCount() : product.getPrice());
            this.writeD(product.getCategory() == 15 ? product.getSilverCoinCount() : 0);
            this.writeC(product.isNew() ? 6 : (product.isHot() ? 5 : 0));
            this.writeC(product.getMinVipLevel());
            this.writeC(product.getMaxVipLevel());
            this.writeC(product.getComponents().size());
            for (ProductItemComponent component : product.getComponents()) {
                this.writeD(component.getId());
                this.writeD((int)component.getCount());
            }
        }
    }
}

