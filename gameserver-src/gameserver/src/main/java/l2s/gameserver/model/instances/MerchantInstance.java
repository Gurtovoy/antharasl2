/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.collections.MultiValueSet
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.instances;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Collection;
import java.util.StringTokenizer;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.BuyListHolder;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.MapRegionManager;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.c2s.RequestBuyItem;
import l2s.gameserver.network.l2.c2s.RequestExRefundItem;
import l2s.gameserver.network.l2.c2s.RequestPreviewItem;
import l2s.gameserver.network.l2.c2s.RequestSellItem;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExBuySellListPacket;
import l2s.gameserver.network.l2.s2c.ExGetPremiumItemListPacket;
import l2s.gameserver.network.l2.s2c.ShopPreviewListPacket;
import l2s.gameserver.templates.mapregion.DomainArea;
import l2s.gameserver.templates.npc.BuyListTemplate;
import l2s.gameserver.templates.npc.NpcTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MerchantInstance
extends NpcInstance {
    private static final Logger _log = LoggerFactory.getLogger(MerchantInstance.class);
    private final TIntObjectMap<BuyListTemplate> _buyLists;

    public MerchantInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
        Collection<BuyListTemplate> buyLists = BuyListHolder.getInstance().getBuyLists(this.getNpcId());
        this._buyLists = new TIntObjectHashMap(buyLists.size());
        for (BuyListTemplate b : buyLists) {
            BuyListTemplate buyList = b.clone();
            this._buyLists.put(buyList.getId(), buyList);
            this._buyLists.put(buyList.getListId(), buyList);
        }
    }

    private void showWearWindow(Player player, int val) {
        if (!player.getPlayerAccess().UseShop) {
            return;
        }
        BuyListTemplate list = this.getBuyList(val);
        if (list != null) {
            ShopPreviewListPacket bl = new ShopPreviewListPacket(list, player);
            player.sendPacket((IBroadcastPacket)bl);
        } else {
            _log.warn("no buylist with id:" + val);
            player.sendActionFailed();
        }
    }

    protected void showShopWindow(Player player, int listId, boolean tax) {
        BuyListTemplate list;
        Castle castle;
        if (!player.getPlayerAccess().UseShop) {
            return;
        }
        double sellTaxRate = 0.0;
        double buyTaxRate = 0.0;
        if (tax && (castle = this.getCastle(player)) != null) {
            sellTaxRate = castle.getSellTaxRate();
            buyTaxRate = castle.getBuyTaxRate();
        }
        if ((list = this.getBuyList(listId)) == null || list.getNpcId() == this.getNpcId()) {
            player.sendPacket(new ExBuySellListPacket.BuyList(list, player, sellTaxRate), new ExBuySellListPacket.SellRefundList(player, false, buyTaxRate));
        } else {
            _log.warn("[L2MerchantInstance] possible client hacker: " + player.getName() + " attempting to buy from GM shop! < Ban him!");
            _log.warn("buylist id:" + listId + " / list_npc = " + list.getNpcId() + " / npc = " + this.getNpcId());
        }
    }

    protected void showShopWindow(Player player) {
        this.showShopWindow(player, 0, false);
    }

    @Override
    public void onBypassFeedback(Player player, String command) {
        StringTokenizer st = new StringTokenizer(command, " ");
        String actualCommand = st.nextToken();
        if (actualCommand.equalsIgnoreCase("Buy") || actualCommand.equalsIgnoreCase("Sell")) {
            int val = 0;
            if (st.countTokens() > 0) {
                val = Integer.parseInt(st.nextToken());
            }
            this.showShopWindow(player, val, true);
        } else if (actualCommand.equalsIgnoreCase("Wear")) {
            if (st.countTokens() < 1) {
                return;
            }
            int val = Integer.parseInt(st.nextToken());
            this.showWearWindow(player, val);
        } else if (actualCommand.equalsIgnoreCase("ReceivePremium")) {
            if (player.getPremiumItemList().isEmpty()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NO_MORE_VITAMIN_ITEMS_TO_BE_FOUND);
                return;
            }
            player.sendPacket((IBroadcastPacket)new ExGetPremiumItemListPacket(player));
        } else {
            super.onBypassFeedback(player, command);
        }
    }

    @Override
    public Castle getCastle(Player player) {
        if (Config.SERVICES_OFFSHORE_NO_CASTLE_TAX || this.getReflection() == ReflectionManager.PARNASSUS && Config.SERVICES_PARNASSUS_NOTAX) {
            return null;
        }
        if (this.getReflection() == ReflectionManager.GIRAN_HARBOR || this.getReflection() == ReflectionManager.PARNASSUS) {
            String var = player.getVar("backCoords");
            if (var != null && !var.isEmpty()) {
                Location loc = Location.parseLoc(var);
                DomainArea domain = MapRegionManager.getInstance().getRegionData(DomainArea.class, loc);
                if (domain != null) {
                    return ResidenceHolder.getInstance().getResidence(Castle.class, domain.getId());
                }
            }
            return super.getCastle();
        }
        return super.getCastle(player);
    }

    @Override
    public boolean canPassPacket(Player player, Class<? extends L2GameClientPacket> packet, Object ... arg) {
        return packet == RequestBuyItem.class || packet == RequestSellItem.class || packet == RequestExRefundItem.class || packet == RequestPreviewItem.class || super.canPassPacket(player, packet, arg);
    }

    @Override
    public BuyListTemplate getBuyList(int listId) {
        return (BuyListTemplate)this._buyLists.get(listId);
    }

    @Override
    protected void onSpawn() {
        for (BuyListTemplate buyList : this._buyLists.valueCollection()) {
            buyList.refresh();
        }
        super.onSpawn();
    }
}

