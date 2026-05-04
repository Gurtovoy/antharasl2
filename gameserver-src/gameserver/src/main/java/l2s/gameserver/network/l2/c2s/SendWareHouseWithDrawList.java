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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SendWareHouseWithDrawList
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(SendWareHouseWithDrawList.class);
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
        Warehouse warehouse = null;
        String logType = null;
        if (activeChar.getUsingWarehouseType() == Warehouse.WarehouseType.PRIVATE) {
            warehouse = activeChar.getWarehouse();
            logType = "WarehouseWithdraw";
        } else if (activeChar.getUsingWarehouseType() == Warehouse.WarehouseType.CLAN) {
            logType = "ClanWarehouseWithdraw";
            boolean canWithdrawCWH = false;
            if (activeChar.getClan() != null && (activeChar.getClanPrivileges() & 8) == 8 && (Config.ALT_ALLOW_OTHERS_WITHDRAW_FROM_CLAN_WAREHOUSE || activeChar.isClanLeader() || activeChar.getVarBoolean("canWhWithdraw"))) {
                canWithdrawCWH = true;
            }
            if (!canWithdrawCWH) {
                return;
            }
            warehouse = activeChar.getClan().getWarehouse();
        } else if (activeChar.getUsingWarehouseType() == Warehouse.WarehouseType.FREIGHT) {
            warehouse = activeChar.getFreight();
            logType = "FreightWithdraw";
        } else {
            _log.warn("Error retrieving a warehouse object for char " + activeChar.getName() + " - using warehouse type: " + (Object)((Object)activeChar.getUsingWarehouseType()));
            return;
        }
        PcInventory inventory = activeChar.getInventory();
        inventory.writeLock();
        warehouse.writeLock();
        try {
            ItemInstance item;
            int i;
            long weight = 0L;
            int slots = 0;
            for (i = 0; i < this._count; ++i) {
                item = warehouse.getItemByObjectId(this._items[i]);
                if (item == null || item.getCount() < this._itemQ[i]) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.INCORRECT_ITEM_COUNT);
                    return;
                }
                weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)item.getTemplate().getWeight(), (long)this._itemQ[i]));
                if (item.isStackable() && inventory.getItemByItemId(item.getItemId()) != null) continue;
                ++slots;
            }
            if (!activeChar.getInventory().validateCapacity(slots)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
                return;
            }
            if (!activeChar.getInventory().validateWeight(weight)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
                return;
            }
            for (i = 0; i < this._count; ++i) {
                item = warehouse.removeItemByObjectId(this._items[i], this._itemQ[i]);
                Log.LogItem(activeChar, logType, item);
                activeChar.getInventory().addItem(item);
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

