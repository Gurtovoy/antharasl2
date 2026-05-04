/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.math.SafeMath;
import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExBuySellListPacket;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.NpcUtils;
import org.apache.commons.lang3.ArrayUtils;

public class RequestSellItem
extends L2GameClientPacket {
    private int _listId;
    private int _count;
    private int[] _items;
    private long[] _itemQ;

    @Override
    protected boolean readImpl() {
        this._listId = this.readD();
        this._count = this.readD();
        if (this._count * 16 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        this._itemQ = new long[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._items[i] = this.readD();
            this.readD();
            this._itemQ[i] = this.readQ();
            if (this._itemQ[i] >= 1L && ArrayUtils.indexOf((int[])this._items, (int)this._items[i]) >= i) continue;
            this._count = 0;
            break;
        }
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._count == 0) {
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
        NpcInstance merchant = NpcUtils.canPassPacket(activeChar, this, new Object[0]);
        if (!Config.BBS_SELL_ITEMS_ENABLED && merchant == null && !activeChar.isGM()) {
            activeChar.sendActionFailed();
            return;
        }
        long totalPrice = 0L;
        long tax = 0L;
        double taxRate = 0.0;
        Castle castle = null;
        if (merchant != null && (castle = merchant.getCastle(activeChar)) != null) {
            taxRate = castle.getBuyTaxRate();
        }
        PcInventory inventory = activeChar.getInventory();
        inventory.writeLock();
        activeChar.getRefund().writeLock();
        try {
            for (int i = 0; i < this._count; ++i) {
                ItemInstance item;
                int objectId = this._items[i];
                long count = this._itemQ[i];
                if (count <= 0L || (item = inventory.getItemByObjectId(objectId)) == null || item.getCount() < count || !item.canBeSold(activeChar)) continue;
                totalPrice = SafeMath.addAndCheck((long)totalPrice, (long)(Config.ALT_SELL_ITEM_ONE_ADENA ? 1L : SafeMath.mulAndCheck((long)item.getReferencePrice(), (long)count) / 2L));
                if (Config.ALLOW_ITEMS_REFUND) {
                    ItemInstance refund = inventory.removeItemByObjectId(objectId, count);
                    Log.LogItem(activeChar, "RefundSell", refund);
                    activeChar.getRefund().addItem(refund);
                    continue;
                }
                inventory.destroyItemByObjectId(objectId, count);
                Log.LogItem((Creature)activeChar, "RefundSell", item, count);
            }
        }
        catch (ArithmeticException ae) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        finally {
            inventory.writeUnlock();
            activeChar.getRefund().writeUnlock();
        }
        tax = (long)((double)totalPrice * taxRate);
        activeChar.addAdena(totalPrice -= tax);
        if (castle != null && tax > 0L && castle.getOwnerId() > 0 && activeChar.getReflection().isMain()) {
            castle.addToTreasury(tax, true);
        }
        activeChar.sendPacket((IBroadcastPacket)new ExBuySellListPacket.SellRefundList(activeChar, true, 0.0));
        activeChar.sendChanges();
    }
}

