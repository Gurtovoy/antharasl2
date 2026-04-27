/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestDropItem
extends L2GameClientPacket {
    private int _objectId;
    private long _count;
    private Location _loc;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._count = this.readQ();
        this._loc = new Location(this.readD(), this.readD(), this.readD());
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._count < 1L || this._loc.isNull()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (!Config.ALLOW_DISCARDITEM) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestDropItem.Disallowed"));
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
            return;
        }
        if (activeChar.isSitting() || activeChar.isDropDisabled()) {
            activeChar.sendActionFailed();
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
        if (!activeChar.isInRangeSq(this._loc, 22500L) || Math.abs(this._loc.z - activeChar.getZ()) > 50) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DISCARD_SOMETHING_THAT_FAR_AWAY_FROM_YOU);
            return;
        }
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._objectId);
        if (item == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (!item.canBeDropped(activeChar, false)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_ITEM_CANNOT_BE_DISCARDED);
            return;
        }
        if (!item.getTemplate().dropItem(activeChar, item, this._count, this._loc)) {
            activeChar.sendActionFailed();
        }
    }
}

