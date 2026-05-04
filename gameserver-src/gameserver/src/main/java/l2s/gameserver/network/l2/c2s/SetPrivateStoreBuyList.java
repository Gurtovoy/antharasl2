/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.math.SafeMath;
import l2s.gameserver.data.string.ItemNameHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PrivateStoreBuyManageList;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.utils.TradeHelper;

public class SetPrivateStoreBuyList
extends L2GameClientPacket {
    private List<BuyItemInfo> _items = Collections.emptyList();

    @Override
    protected boolean readImpl() {
        int count = this.readD();
        if (count * 40 > this._buf.remaining() || count > Short.MAX_VALUE || count < 1) {
            return false;
        }
        this._items = new ArrayList<BuyItemInfo>();
        for (int i = 0; i < count; ++i) {
            int s;
            BuyItemInfo item = new BuyItemInfo();
            item.id = this.readD();
            item.enchant_level = this.readD();
            item.count = this.readQ();
            item.price = this.readQ();
            if (item.count < 1L || item.price < 1L) break;
            this.readD();
            this.readD();
            this.readH();
            this.readH();
            this.readH();
            this.readH();
            this.readH();
            this.readH();
            this.readH();
            this.readH();
            this.readD();
            int saCount = this.readC();
            for (s = 0; s < saCount; ++s) {
                this.readD();
            }
            saCount = this.readC();
            for (s = 0; s < saCount; ++s) {
                this.readD();
            }
            this._items.add(item);
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player buyer = ((GameClient)this.getClient()).getActiveChar();
        if (buyer == null || this._items.isEmpty()) {
            return;
        }
        if (!TradeHelper.checksIfCanOpenStore(buyer, 3)) {
            buyer.sendActionFailed();
            return;
        }
        CopyOnWriteArrayList<TradeItem> buyList = new CopyOnWriteArrayList<TradeItem>();
        long totalCost = 0L;
        try {
            block2: for (BuyItemInfo i : this._items) {
                ItemTemplate item = ItemHolder.getInstance().getTemplate(i.id);
                if (item == null || i.id == 57) continue;
                if ((long)(item.getReferencePrice() / 2) > i.price) {
                    buyer.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.SetPrivateStoreBuyList.TooLowPrice").addString(ItemNameHolder.getInstance().getItemName(buyer, i.id)).addNumber(item.getReferencePrice() / 2));
                    continue;
                }
                if (item.isStackable()) {
                    for (TradeItem bi : buyList) {
                        if (bi.getItemId() != i.id) continue;
                        bi.setOwnersPrice(i.price);
                        bi.setCount(bi.getCount() + i.count);
                        totalCost = SafeMath.addAndCheck((long)totalCost, (long)SafeMath.mulAndCheck((long)i.count, (long)i.price));
                        continue block2;
                    }
                }
                TradeItem bi = new TradeItem();
                bi.setItemId(i.id);
                bi.setCount(i.count);
                bi.setOwnersPrice(i.price);
                bi.setEnchantLevel(i.enchant_level);
                totalCost = SafeMath.addAndCheck((long)totalCost, (long)SafeMath.mulAndCheck((long)i.count, (long)i.price));
                buyList.add(bi);
            }
        }
        catch (ArithmeticException ae) {
            buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        if (buyList.size() > buyer.getTradeLimit()) {
            buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            buyer.sendPacket((IBroadcastPacket)new PrivateStoreBuyManageList(1, buyer));
            buyer.sendPacket((IBroadcastPacket)new PrivateStoreBuyManageList(2, buyer));
            return;
        }
        if (totalCost > buyer.getAdena()) {
            buyer.sendPacket((IBroadcastPacket)SystemMsg.THE_PURCHASE_PRICE_IS_HIGHER_THAN_THE_AMOUNT_OF_MONEY_THAT_YOU_HAVE_AND_SO_YOU_CANNOT_OPEN_A_PERSONAL_STORE);
            buyer.sendPacket((IBroadcastPacket)new PrivateStoreBuyManageList(1, buyer));
            buyer.sendPacket((IBroadcastPacket)new PrivateStoreBuyManageList(2, buyer));
            return;
        }
        if (!buyList.isEmpty()) {
            buyer.setBuyList(buyList);
            buyer.setPrivateStoreType(3);
            buyer.storePrivateStore();
            buyer.broadcastPrivateStoreInfo();
            buyer.sitDown(null);
            buyer.broadcastCharInfo();
        }
        buyer.sendActionFailed();
    }

    private static class BuyItemInfo {
        public int id;
        public long count;
        public long price;
        public int enchant_level;

        private BuyItemInfo() {
        }
    }
}

