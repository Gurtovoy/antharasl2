package l2s.gameserver.network.l2.c2s;

import l2s.commons.math.SafeMath;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcFreight;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.Log;
import org.apache.commons.lang3.ArrayUtils;

public class RequestPackageSend
extends L2GameClientPacket {
    private static final long _FREIGHT_FEE = 1000L;
    private int _objectId;
    private int _count;
    private int[] _items;
    private long[] _itemQ;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._count = this.readD();
        if (this._count * 12 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        this._itemQ = new long[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._items[i] = this.readD();
            this._itemQ[i] = this.readQ();
            if (this._itemQ[i] >= 1L && ArrayUtils.indexOf((int[])this._items, (int)this._items[i]) >= i) continue;
            this._count = 0;
            return false;
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null || this._count == 0) {
            return;
        }
        if (!player.getPlayerAccess().UseWarehouse) {
            player.sendActionFailed();
            return;
        }
        if (player.isActionsDisabled()) {
            player.sendActionFailed();
            return;
        }
        if (player.isInStoreMode()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
            return;
        }
        if (player.isInTrade()) {
            player.sendActionFailed();
            return;
        }
        NpcInstance whkeeper = player.getLastNpc();
        if (whkeeper == null || !player.checkInteractionDistance(whkeeper)) {
            return;
        }
        if (!player.getAccountChars().containsKey(this._objectId)) {
            return;
        }
        PcInventory inventory = player.getInventory();
        PcFreight freight = new PcFreight(this._objectId);
        freight.restore();
        inventory.writeLock();
        freight.writeLock();
        try {
            int slotsleft = 0;
            long adenaDeposit = 0L;
            slotsleft = Config.FREIGHT_SLOTS - freight.getSize();
            int items = 0;
            for (int i = 0; i < this._count; ++i) {
                ItemInstance item = inventory.getItemByObjectId(this._items[i]);
                if (item == null || item.getCount() < this._itemQ[i] || !item.getTemplate().isFreightable()) {
                    this._items[i] = 0;
                    this._itemQ[i] = 0L;
                    continue;
                }
                if (!item.isStackable() || freight.getItemByItemId(item.getItemId()) == null) {
                    if (slotsleft <= 0) {
                        this._items[i] = 0;
                        this._itemQ[i] = 0L;
                        continue;
                    }
                    --slotsleft;
                }
                if (item.getItemId() == 57) {
                    adenaDeposit = this._itemQ[i];
                }
                ++items;
            }
            if (slotsleft <= 0) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            }
            if (items == 0) {
                player.sendPacket((IBroadcastPacket)SystemMsg.INCORRECT_ITEM_COUNT);
                return;
            }
            long fee = SafeMath.mulAndCheck((long)items, (long)1000L);
            if (fee + adenaDeposit > player.getAdena()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_LACK_THE_FUNDS_NEEDED_TO_PAY_FOR_THIS_TRANSACTION);
                return;
            }
            if (!player.reduceAdena(fee, true)) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                return;
            }
            for (int i = 0; i < this._count; ++i) {
                if (this._items[i] == 0) continue;
                ItemInstance item = inventory.removeItemByObjectId(this._items[i], this._itemQ[i]);
                Log.LogItem(player, "FreightDeposit", item);
                freight.addItem(item);
            }
        }
        catch (ArithmeticException ae) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        finally {
            freight.writeUnlock();
            inventory.writeUnlock();
        }
        player.sendChanges();
        player.sendPacket((IBroadcastPacket)SystemMsg.THE_TRANSACTION_IS_COMPLETE);
    }
}

