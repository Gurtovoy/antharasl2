package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPutItemResultForVariationMake;

public class RequestConfirmTargetItem
extends L2GameClientPacket {
    private int _itemObjId;

    @Override
    protected boolean readImpl() {
        this._itemObjId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (!Config.ALLOW_AUGMENTATION) {
            activeChar.sendActionFailed();
            return;
        }
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._itemObjId);
        if (item == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (item.isAugmented()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ONCE_AN_ITEM_IS_AUGMENTED_IT_CANNOT_BE_AUGMENTED_AGAIN);
            return;
        }
        if (!item.canBeAugmented(activeChar)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_AUGMENT_ITEMS_WHILE_A_PRIVATE_STORE_OR_PRIVATE_WORKSHOP_IS_IN_OPERATION);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isDead()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_AUGMENT_ITEMS_WHILE_DEAD);
            return;
        }
        if (activeChar.isParalyzed()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_AUGMENT_ITEMS_WHILE_PARALYZED);
            return;
        }
        if (activeChar.isFishing()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_AUGMENT_ITEMS_WHILE_FISHING);
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        if (activeChar.isSitting()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_AUGMENT_ITEMS_WHILE_SITTING_DOWN);
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendPacket(new ExPutItemResultForVariationMake(this._itemObjId), SystemMsg.SELECT_THE_CATALYST_FOR_AUGMENTATION);
    }
}

