/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.LinkedHashMap;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PrivateStoreManageList;
import l2s.gameserver.utils.TradeHelper;
import org.apache.commons.lang3.ArrayUtils;

public class SetPrivateStoreSellList
extends L2GameClientPacket {
    private int _count;
    private boolean _package;
    private int[] _items;
    private long[] _itemQ;
    private long[] _itemP;

    @Override
    protected boolean readImpl() {
        this._package = this.readD() == 1;
        this._count = this.readD();
        if (this._count * 20 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        this._itemQ = new long[this._count];
        this._itemP = new long[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._items[i] = this.readD();
            this._itemQ[i] = this.readQ();
            this._itemP[i] = this.readQ();
            if (this._itemQ[i] >= 1L && this._itemP[i] >= 0L && ArrayUtils.indexOf((int[])this._items, (int)this._items[i]) >= i) continue;
            this._count = 0;
            break;
        }
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player seller = ((GameClient)this.getClient()).getActiveChar();
        if (seller == null || this._count == 0) {
            return;
        }
        if (!TradeHelper.checksIfCanOpenStore(seller, this._package ? 8 : 1)) {
            seller.sendActionFailed();
            return;
        }
        LinkedHashMap<Integer, TradeItem> sellList = new LinkedHashMap<Integer, TradeItem>();
        seller.getInventory().writeLock();
        try {
            for (int i = 0; i < this._count; ++i) {
                int objectId = this._items[i];
                long count = this._itemQ[i];
                long price = this._itemP[i];
                ItemInstance item = seller.getInventory().getItemByObjectId(objectId);
                if (item == null || item.getCount() < count || !item.canBePrivateStore(seller) || item.getItemId() == 57) continue;
                if (item.getPriceLimitForItem() != 0L && price > item.getPriceLimitForItem()) {
                    price = item.getPriceLimitForItem();
                }
                TradeItem temp = new TradeItem(item);
                temp.setCount(count);
                temp.setOwnersPrice(price);
                sellList.put(temp.getObjectId(), temp);
            }
        }
        finally {
            seller.getInventory().writeUnlock();
        }
        if (sellList.size() > seller.getTradeLimit()) {
            seller.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            seller.sendPacket((IBroadcastPacket)new PrivateStoreManageList(1, seller, this._package));
            seller.sendPacket((IBroadcastPacket)new PrivateStoreManageList(2, seller, this._package));
            return;
        }
        if (!sellList.isEmpty()) {
            seller.setSellList(this._package, sellList);
            seller.setPrivateStoreType(this._package ? 8 : 1);
            seller.storePrivateStore();
            seller.broadcastPrivateStoreInfo();
            seller.sitDown(null);
            seller.broadcastCharInfo();
        }
        seller.sendActionFailed();
    }
}

