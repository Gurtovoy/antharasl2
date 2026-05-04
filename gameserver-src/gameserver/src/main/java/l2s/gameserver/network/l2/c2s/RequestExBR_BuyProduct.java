/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.ProductDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ProductHistoryItem;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExBR_BuyProductPacket;
import l2s.gameserver.network.l2.s2c.ExBR_NewIConCashBtnWnd;
import l2s.gameserver.network.l2.s2c.ReciveVipInfo;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.product.ProductItem;
import l2s.gameserver.templates.item.product.ProductItemComponent;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.Log;

public class RequestExBR_BuyProduct
extends L2GameClientPacket {
    private int _productId;
    private int _count;

    @Override
    protected boolean readImpl() {
        this._productId = this.readD();
        this._count = this.readD();
        return true;
    }

    
    @Override
    protected void runImpl() {
        if (!Config.EX_USE_PRIME_SHOP) {
            return;
        }
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._count > 100) return;
        if (this._count <= 0) {
            return;
        }
        ProductItem product = ProductDataHolder.getInstance().getProduct(this._productId);
        if (product == null) {
            activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_WRONG_PRODUCT);
            return;
        }
        if (!product.isOnSale() || System.currentTimeMillis() < product.getStartTimeSale() || System.currentTimeMillis() > product.getEndTimeSale()) {
            activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_SALE_PERIOD_ENDED);
            return;
        }
        activeChar.getProductHistoryList().writeLock();
        try {
            int pointsRequired;
            if (product.getLimit() >= 0) {
                ProductHistoryItem productHistoryItem = activeChar.getProductHistoryList().get(product.getId());
                this._count = productHistoryItem != null ? Math.min(this._count, product.getLimit() - productHistoryItem.getPurchasedCount()) : Math.min(this._count, product.getLimit());
                if (this._count <= 0) {
                    activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_ITEM_LIMITED);
                    return;
                }
            }
            if ((pointsRequired = product.getPrice() * this._count) <= 0 && product.getLimit() == -1) {
                activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_WRONG_PRODUCT);
                return;
            }
            activeChar.getInventory().writeLock();
            try {
                if ((long)pointsRequired > activeChar.getPremiumPoints()) {
                    activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_NOT_ENOUGH_POINTS);
                    return;
                }
                int totalWeight = 0;
                for (ProductItemComponent com : product.getComponents()) {
                    totalWeight += com.getWeight();
                }
                totalWeight *= this._count;
                int totalCount = 0;
                for (ProductItemComponent com : product.getComponents()) {
                    ItemTemplate item = ItemHolder.getInstance().getTemplate(com.getId());
                    if (item == null) {
                        activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_WRONG_PRODUCT);
                        return;
                    }
                    totalCount = (int)((long)totalCount + (item.isStackable() ? 1L : com.getCount() * (long)this._count));
                }
                if (!activeChar.getInventory().validateCapacity(totalCount) || !activeChar.getInventory().validateWeight(totalWeight)) {
                    activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_INVENTORY_FULL);
                    return;
                }
                if (pointsRequired > 0 && !activeChar.reducePremiumPoints(pointsRequired)) {
                    activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_NOT_ENOUGH_POINTS);
                    return;
                }
                activeChar.getVIP().addPoints((int)((double)pointsRequired * activeChar.getVIP().getPointsRefillPercent() / 100.0));
                activeChar.getProductHistoryList().onPurchaseProduct(product, this._count);
                activeChar.sendPacket((IBroadcastPacket)new ExBR_NewIConCashBtnWnd(activeChar));
                for (ProductItemComponent $comp : product.getComponents()) {
                    List<ItemInstance> items = ItemFunctions.addItem(activeChar, $comp.getId(), $comp.getCount() * (long)this._count, true);
                    for (ItemInstance item : items) {
                        Log.LogItem(activeChar, "ItemMallBuy", item);
                    }
                }
                activeChar.sendPacket((IBroadcastPacket)ExBR_BuyProductPacket.RESULT_OK);
                activeChar.sendPacket((IBroadcastPacket)new ReciveVipInfo(activeChar));
                return;
            }
            finally {
                activeChar.getInventory().writeUnlock();
            }
        }
        finally {
            activeChar.getProductHistoryList().writeUnlock();
        }
    }
}

