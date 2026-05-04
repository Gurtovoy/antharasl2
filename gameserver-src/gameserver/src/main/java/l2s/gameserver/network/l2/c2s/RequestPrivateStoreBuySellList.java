/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.math.SafeMath;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPrivateStoreBuyingResult;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.TradeHelper;
import org.apache.commons.lang3.ArrayUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestPrivateStoreBuySellList
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestPrivateStoreBuySellList.class);
    private int _buyerId;
    private int _count;
    private int[] _items;
    private long[] _itemQ;
    private long[] _itemP;

    @Override
    protected boolean readImpl() {
        this._buyerId = this.readD();
        this._count = this.readD();
        if (this._count * 28 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        this._itemQ = new long[this._count];
        this._itemP = new long[this._count];
        for (int i = 0; i < this._count; ++i) {
            int s;
            this._items[i] = this.readD();
            this.readD();
            this.readH();
            this.readH();
            this._itemQ[i] = this.readQ();
            this._itemP[i] = this.readQ();
            if (this._itemQ[i] < 1L || this._itemP[i] < 1L || ArrayUtils.indexOf((int[])this._items, (int)this._items[i]) < i) {
                this._count = 0;
                break;
            }
            this.readD();
            this.readD();
            this.readD();
            int saCount = this.readC();
            for (s = 0; s < saCount; ++s) {
                this.readD();
            }
            saCount = this.readC();
            for (s = 0; s < saCount; ++s) {
                this.readD();
            }
        }
        return true;
    }

    
    @Override
    protected void runImpl() {
        List<TradeItem> buyList;
        Player buyer;
        Player seller;
        block46: {
            seller = ((GameClient)this.getClient()).getActiveChar();
            if (seller == null || this._count == 0) {
                return;
            }
            if (seller.isActionsDisabled()) {
                seller.sendActionFailed();
                return;
            }
            if (seller.isInStoreMode()) {
                seller.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
                return;
            }
            if (seller.isInTrade()) {
                seller.sendActionFailed();
                return;
            }
            if (seller.isFishing()) {
                seller.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING_2);
                return;
            }
            if (seller.isInTrainingCamp()) {
                seller.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
                return;
            }
            if (!seller.getPlayerAccess().UseTrade) {
                seller.sendPacket((IBroadcastPacket)SystemMsg.SOME_LINEAGE_II_FEATURES_HAVE_BEEN_LIMITED_FOR_FREE_TRIALS_____);
                return;
            }
            buyer = (Player)seller.getVisibleObject(this._buyerId);
            if (buyer == null || buyer.getPrivateStoreType() != 3 || !seller.checkInteractionDistance(buyer)) {
                seller.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_SELL_HAS_FAILED);
                seller.sendActionFailed();
                return;
            }
            buyList = buyer.getBuyList();
            if (buyList.isEmpty()) {
                seller.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_SELL_HAS_FAILED);
                seller.sendActionFailed();
                return;
            }
            ArrayList<TradeItem> sellList = new ArrayList<TradeItem>();
            long totalCost = 0L;
            int slots = 0;
            long weight = 0L;
            buyer.getInventory().writeLock();
            seller.getInventory().writeLock();
            try {
                block24: for (int i = 0; i < this._count; ++i) {
                    int objectId = this._items[i];
                    long count = this._itemQ[i];
                    long price = this._itemP[i];
                    ItemInstance item = seller.getInventory().getItemByObjectId(objectId);
                    if (item == null || item.getCount() < count) break;
                    if (!item.canBePrivateStore(seller)) {
                        break;
                    }
                    TradeItem si = null;
                    for (TradeItem bi : buyList) {
                        if (bi.getItemId() != item.getItemId() || (item.isArmor() || item.isAccessory() || item.isWeapon()) && item.getEnchantLevel() != bi.getEnchantLevel() || bi.getOwnersPrice() != price) continue;
                        if (count > bi.getCount()) {
                            break block46;
                        }
                        totalCost = SafeMath.addAndCheck((long)totalCost, (long)SafeMath.mulAndCheck((long)count, (long)price));
                        weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)count, (long)item.getTemplate().getWeight()));
                        if (!item.isStackable() || buyer.getInventory().getItemByItemId(item.getItemId()) == null) {
                            ++slots;
                        }
                        si = new TradeItem();
                        si.setObjectId(objectId);
                        si.setItemId(item.getItemId());
                        si.setCount(count);
                        si.setOwnersPrice(price);
                        sellList.add(si);
                        continue block24;
                    }
                }
            }
            catch (ArithmeticException ae) {
                sellList.clear();
                seller.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
                return;
            }
            finally {
                try {
                    if (sellList.size() != this._count) {
                        seller.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_SELL_HAS_FAILED);
                        seller.sendActionFailed();
                        return;
                    }
                    if (!buyer.getInventory().validateWeight(weight)) {
                        buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
                        seller.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_SELL_HAS_FAILED);
                        seller.sendActionFailed();
                        return;
                    }
                    if (!buyer.getInventory().validateCapacity(slots)) {
                        buyer.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
                        seller.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_SELL_HAS_FAILED);
                        seller.sendActionFailed();
                        return;
                    }
                    if (!buyer.reduceAdena(totalCost)) {
                        buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                        seller.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_SELL_HAS_FAILED);
                        seller.sendActionFailed();
                        return;
                    }
                    for (TradeItem si : sellList) {
                        ItemInstance item = seller.getInventory().removeItemByObjectId(si.getObjectId(), si.getCount());
                        for (TradeItem bi : buyList) {
                            if (bi.getItemId() != si.getItemId() || bi.getOwnersPrice() != si.getOwnersPrice()) continue;
                            bi.setCount(bi.getCount() - si.getCount());
                            if (bi.getCount() >= 1L) break;
                            buyList.remove(bi);
                            break;
                        }
                        Log.LogItem(seller, "PrivateStoreSell", item);
                        Log.LogItem(buyer, "PrivateStoreBuy", item);
                        buyer.getInventory().addItem(item);
                        TradeHelper.purchaseItem(buyer, seller, si);
                        buyer.sendPacket((IBroadcastPacket)new ExPrivateStoreBuyingResult(si.getObjectId(), si.getCount(), seller.getName()));
                    }
                    long tax = TradeHelper.getTax(seller, totalCost);
                    if (tax > 0L) {
                        totalCost -= tax;
                    }
                    seller.addAdena(totalCost);
                    buyer.storePrivateStore();
                }
                finally {
                    seller.getInventory().writeUnlock();
                    buyer.getInventory().writeUnlock();
                }
            }
        }
        if (buyList.isEmpty()) {
            TradeHelper.cancelStore(buyer);
        }
        seller.sendChanges();
        buyer.sendChanges();
        seller.sendActionFailed();
    }
}

