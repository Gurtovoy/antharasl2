package l2s.gameserver.network.l2.c2s;

import l2s.commons.math.SafeMath;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.model.items.Warehouse;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.Log;
import org.apache.commons.lang3.ArrayUtils;

public class SendWareHouseDepositList
extends L2GameClientPacket {
    private static final long _WAREHOUSE_FEE = 30L;
    private int _count;
    private int[] _items;
    private long[] _itemQ;

    @Override
    protected boolean readImpl() {
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
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._count == 0) {
            return;
        }
        if (!activeChar.getPlayerAccess().UseWarehouse) {
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
        NpcInstance whkeeper = activeChar.getLastNpc();
        if (!(Config.BBS_WAREHOUSE_ENABLED || whkeeper != null && activeChar.checkInteractionDistance(whkeeper))) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_MOVED_TOO_FAR_AWAY_FROM_THE_WAREHOUSE_TO_PERFORM_THAT_ACTION);
            return;
        }
        PcInventory inventory = activeChar.getInventory();
        boolean privatewh = activeChar.getUsingWarehouseType() != Warehouse.WarehouseType.CLAN;
        Warehouse warehouse = privatewh ? activeChar.getWarehouse() : activeChar.getClan().getWarehouse();
        inventory.writeLock();
        warehouse.writeLock();
        try {
            int slotsleft = 0;
            long adenaDeposit = 0L;
            slotsleft = privatewh ? activeChar.getWarehouseLimit() - warehouse.getSize() : activeChar.getClan().getWhBonus() + Config.WAREHOUSE_SLOTS_CLAN - warehouse.getSize();
            int items = 0;
            for (int i = 0; i < this._count; ++i) {
                ItemInstance item = inventory.getItemByObjectId(this._items[i]);
                if (item == null || item.getCount() < this._itemQ[i] || !item.canBeStored(activeChar, privatewh)) {
                    this._items[i] = 0;
                    this._itemQ[i] = 0L;
                    continue;
                }
                if (!item.isStackable() || warehouse.getItemByItemId(item.getItemId()) == null) {
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
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_WAREHOUSE_IS_FULL);
            }
            if (items == 0) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.INCORRECT_ITEM_COUNT);
                return;
            }
            long fee = SafeMath.mulAndCheck((long)items, (long)30L);
            if (fee + adenaDeposit > activeChar.getAdena()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_LACK_THE_FUNDS_NEEDED_TO_PAY_FOR_THIS_TRANSACTION);
                return;
            }
            if (!activeChar.reduceAdena(fee, true)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                return;
            }
            for (int i = 0; i < this._count; ++i) {
                if (this._items[i] == 0) continue;
                ItemInstance item = inventory.removeItemByObjectId(this._items[i], this._itemQ[i]);
                Log.LogItem(activeChar, privatewh ? "WarehouseDeposit" : "ClanWarehouseDeposit", item);
                warehouse.addItem(item);
            }
        }
        catch (ArithmeticException ae) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        finally {
            warehouse.writeUnlock();
            inventory.writeUnlock();
        }
        activeChar.sendChanges();
        activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_TRANSACTION_IS_COMPLETE);
    }
}

