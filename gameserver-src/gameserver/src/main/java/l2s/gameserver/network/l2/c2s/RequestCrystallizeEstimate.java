/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExGetCrystalizingEstimation;
import l2s.gameserver.utils.ItemFunctions;

public class RequestCrystallizeEstimate
extends L2GameClientPacket {
    private int _objectId;
    private long _count;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._count = this.readQ();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendActionFailed();
            return;
        }
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._objectId);
        if (item == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (!item.canBeCrystallized(activeChar)) {
            if (item.isFlagNoCrystallize()) {
                ItemFunctions.deleteItem((Playable)activeChar, item, 1L, true);
            } else {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_ITEM_CANNOT_BE_CRYSTALLIZED);
            }
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
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
        int externalOrdinal = item.getTemplate().getGrade().extOrdinal();
        int level = activeChar.getSkillLevel(248);
        if (level < 1 || externalOrdinal > level) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_CRYSTALLIZE_THIS_ITEM);
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExGetCrystalizingEstimation(item));
    }
}

