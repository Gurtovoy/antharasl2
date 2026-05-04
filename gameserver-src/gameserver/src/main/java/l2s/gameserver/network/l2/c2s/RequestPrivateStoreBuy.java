package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import l2s.commons.math.SafeMath;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPrivateStoreSellingResult;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.TradeHelper;
import org.apache.commons.lang3.ArrayUtils;

public class RequestPrivateStoreBuy
extends L2GameClientPacket {
    private int _sellerId;
    private int _count;
    private int[] _items;
    private long[] _itemQ;
    private long[] _itemP;

    @Override
    protected boolean readImpl() {
        this._sellerId = this.readD();
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
            if (this._itemQ[i] >= 1L && this._itemP[i] >= 1L && ArrayUtils.indexOf((int[])this._items, (int)this._items[i]) >= i) continue;
            this._count = 0;
            break;
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Map<Integer, TradeItem> sellList;
        Player seller;
        Player buyer;
        block46: {
            buyer = ((GameClient)this.getClient()).getActiveChar();
            if (buyer == null || this._count == 0) {
                return;
            }
            if (buyer.isActionsDisabled()) {
                buyer.sendActionFailed();
                return;
            }
            if (buyer.isInStoreMode()) {
                buyer.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
                return;
            }
            if (buyer.isInTrade()) {
                buyer.sendActionFailed();
                return;
            }
            if (buyer.isFishing()) {
                buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING_2);
                return;
            }
            if (buyer.isInTrainingCamp()) {
                buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
                return;
            }
            if (!buyer.getPlayerAccess().UseTrade) {
                buyer.sendPacket((IBroadcastPacket)SystemMsg.SOME_LINEAGE_II_FEATURES_HAVE_BEEN_LIMITED_FOR_FREE_TRIALS_____);
                return;
            }
            seller = (Player)buyer.getVisibleObject(this._sellerId);
            if (seller == null || seller.getPrivateStoreType() != 1 && seller.getPrivateStoreType() != 8 || !seller.checkInteractionDistance(buyer)) {
                buyer.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_TRADE_HAS_FAILED);
                buyer.sendActionFailed();
                return;
            }
            sellList = seller.getSellList();
            if (sellList.isEmpty()) {
                buyer.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_TRADE_HAS_FAILED);
                buyer.sendActionFailed();
                return;
            }
            ArrayList<TradeItem> buyList = new ArrayList<TradeItem>();
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
                    TradeItem bi = null;
                    for (TradeItem si : sellList.values()) {
                        if (si.getObjectId() != objectId || si.getOwnersPrice() != price) continue;
                        if (count > si.getCount()) {
                            break block46;
                        }
                        ItemInstance item = seller.getInventory().getItemByObjectId(objectId);
                        if (item == null || item.getCount() < count) break block46;
                        if (!item.canBePrivateStore(seller)) {
                            break block46;
                        }
                        totalCost = SafeMath.addAndCheck((long)totalCost, (long)SafeMath.mulAndCheck((long)count, (long)price));
                        weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)count, (long)item.getTemplate().getWeight()));
                        if (!item.isStackable() || buyer.getInventory().getItemByItemId(item.getItemId()) == null) {
                            ++slots;
                        }
                        bi = new TradeItem();
                        bi.setObjectId(objectId);
                        bi.setItemId(item.getItemId());
                        bi.setCount(count);
                        bi.setOwnersPrice(price);
                        buyList.add(bi);
                        continue block24;
                    }
                }
            }
            catch (ArithmeticException ae) {
                buyList.clear();
                buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
                return;
            }
            finally {
                try {
                    if (buyList.size() != this._count || seller.getPrivateStoreType() == 8 && buyList.size() != sellList.size()) {
                        buyer.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTEMPT_TO_TRADE_HAS_FAILED);
                        buyer.sendActionFailed();
                        return;
                    }
                    if (!buyer.getInventory().validateWeight(weight)) {
                        buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
                        buyer.sendActionFailed();
                        return;
                    }
                    if (!buyer.getInventory().validateCapacity(slots)) {
                        buyer.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
                        buyer.sendActionFailed();
                        return;
                    }
                    if (!buyer.reduceAdena(totalCost)) {
                        buyer.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                        buyer.sendActionFailed();
                        return;
                    }
                    for (TradeItem bi : buyList) {
                        ItemInstance item = seller.getInventory().removeItemByObjectId(bi.getObjectId(), bi.getCount());
                        Iterator<Map.Entry<Integer, TradeItem>> iterator = sellList.entrySet().iterator();
                        while (iterator.hasNext()) {
                            Map.Entry<Integer, TradeItem> entry = iterator.next();
                            TradeItem si = entry.getValue();
                            if (si.getObjectId() != bi.getObjectId()) continue;
                            si.setCount(si.getCount() - bi.getCount());
                            if (si.getCount() >= 1L) break;
                            iterator.remove();
                            break;
                        }
                        Log.LogItem(seller, "PrivateStoreSell", item);
                        Log.LogItem(buyer, "PrivateStoreBuy", item);
                        buyer.getInventory().addItem(item);
                        TradeHelper.purchaseItem(buyer, seller, bi);
                        seller.sendPacket((IBroadcastPacket)new ExPrivateStoreSellingResult(bi.getObjectId(), bi.getCount(), buyer.getName()));
                    }
                    long tax = TradeHelper.getTax(seller, totalCost);
                    if (tax > 0L) {
                        totalCost -= tax;
                    }
                    seller.addAdena(totalCost);
                    seller.storePrivateStore();
                }
                finally {
                    seller.getInventory().writeUnlock();
                    buyer.getInventory().writeUnlock();
                }
            }
        }
        if (sellList.isEmpty()) {
            TradeHelper.cancelStore(seller);
        }
        seller.sendChanges();
        buyer.sendChanges();
        buyer.sendActionFailed();
    }
}

