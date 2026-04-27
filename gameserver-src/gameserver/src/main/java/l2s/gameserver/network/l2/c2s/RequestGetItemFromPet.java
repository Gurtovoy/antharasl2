/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.model.items.PetInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestGetItemFromPet
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestGetItemFromPet.class);
    private int _objectId;
    private long _amount;
    private int _unknown;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._amount = this.readQ();
        this._unknown = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._amount < 1L) {
            return;
        }
        PetInstance pet = activeChar.getPet();
        if (pet == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isOutOfControl()) {
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
        PetInventory petInventory = pet.getInventory();
        PcInventory playerInventory = activeChar.getInventory();
        ItemInstance item = petInventory.getItemByObjectId(this._objectId);
        if (item == null || item.getCount() < this._amount || item.isEquipped()) {
            activeChar.sendActionFailed();
            return;
        }
        int slots = 0;
        long weight = (long)item.getTemplate().getWeight() * this._amount;
        if (!item.getTemplate().isStackable() || activeChar.getInventory().getItemByItemId(item.getItemId()) == null) {
            slots = 1;
        }
        if (!activeChar.getInventory().validateWeight(weight)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
            return;
        }
        if (!activeChar.getInventory().validateCapacity(slots)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
            return;
        }
        playerInventory.addItem(petInventory.removeItemByObjectId(this._objectId, this._amount));
        pet.sendChanges();
        activeChar.sendChanges();
    }
}

