package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import l2s.commons.math.SafeMath;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExBuySellListPacket;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.NpcUtils;
import org.apache.commons.lang3.ArrayUtils;

public class RequestExRefundItem
extends L2GameClientPacket {
    private int _listId;
    private int _count;
    private int[] _items;

    @Override
    protected boolean readImpl() {
        this._listId = this.readD();
        this._count = this.readD();
        if (this._count * 4 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._items[i] = this.readD();
            if (ArrayUtils.indexOf((int[])this._items, (int)this._items[i]) >= i) continue;
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
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._count == 0) {
            return;
        }
        if (!Config.ALLOW_ITEMS_REFUND) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isFishing()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING);
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        if (!Config.ALT_GAME_KARMA_PLAYER_CAN_SHOP && activeChar.isPK() && !activeChar.isGM()) {
            activeChar.sendActionFailed();
            return;
        }
        NpcInstance npc = NpcUtils.canPassPacket(activeChar, this, new Object[0]);
        if (npc == null && !activeChar.isGM()) {
            activeChar.sendActionFailed();
            return;
        }
        double buyTaxRate = 0.0;
        Castle castle = null;
        if (npc != null && (castle = npc.getCastle(activeChar)) != null) {
            buyTaxRate = castle.getBuyTaxRate();
        }
        activeChar.getInventory().writeLock();
        activeChar.getRefund().writeLock();
        try {
            int slots = 0;
            long weight = 0L;
            long totalPrice = 0L;
            ArrayList<ItemInstance> refundList = new ArrayList<ItemInstance>();
            for (int objId : this._items) {
                ItemInstance item = activeChar.getRefund().getItemByObjectId(objId);
                if (item == null) continue;
                totalPrice = Config.ALT_SELL_ITEM_ONE_ADENA ? 1L : SafeMath.addAndCheck((long)totalPrice, (long)(SafeMath.mulAndCheck((long)item.getCount(), (long)item.getReferencePrice()) / 2L));
                weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)item.getCount(), (long)item.getTemplate().getWeight()));
                if (!item.isStackable() || activeChar.getInventory().getItemByItemId(item.getItemId()) == null) {
                    ++slots;
                }
                refundList.add(item);
            }
            if (refundList.isEmpty()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.INCORRECT_ITEM_COUNT);
                activeChar.sendActionFailed();
                return;
            }
            if (!activeChar.getInventory().validateWeight(weight)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
                activeChar.sendActionFailed();
                return;
            }
            if (!activeChar.getInventory().validateCapacity(slots)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
                activeChar.sendActionFailed();
                return;
            }
            if (!activeChar.reduceAdena(totalPrice)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                activeChar.sendActionFailed();
                return;
            }
            java.util.Iterator<ItemInstance> object = refundList.iterator();
            while (object.hasNext()) {
                ItemInstance item = object.next();
                ItemInstance refund = activeChar.getRefund().removeItem(item);
                Log.LogItem(activeChar, "RefundReturn", refund);
                activeChar.getInventory().addItem(refund);
            }
        }
        catch (ArithmeticException ae) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        finally {
            activeChar.getInventory().writeUnlock();
            activeChar.getRefund().writeUnlock();
        }
        activeChar.sendPacket((IBroadcastPacket)new ExBuySellListPacket.SellRefundList(activeChar, true, buyTaxRate));
        activeChar.sendChanges();
    }
}

