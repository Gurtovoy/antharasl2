package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPutCommissionResultForVariationMake;
import l2s.gameserver.templates.item.support.variation.VariationFee;
import l2s.gameserver.utils.VariationUtils;

public class RequestConfirmGemStone
extends L2GameClientPacket {
    private int _targetItemObjId;
    private int _refinerItemObjId;
    private int _feeItemObjectId;
    private long _feeItemCount;

    @Override
    protected boolean readImpl() {
        this._targetItemObjId = this.readD();
        this._refinerItemObjId = this.readD();
        this._feeItemObjectId = this.readD();
        this._feeItemCount = this.readQ();
        return true;
    }

    @Override
    protected void runImpl() {
        if (this._feeItemCount <= 0L) {
            return;
        }
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (!Config.ALLOW_AUGMENTATION) {
            activeChar.sendActionFailed();
            return;
        }
        ItemInstance targetItem = activeChar.getInventory().getItemByObjectId(this._targetItemObjId);
        ItemInstance refinerItem = activeChar.getInventory().getItemByObjectId(this._refinerItemObjId);
        ItemInstance feeItem = activeChar.getInventory().getItemByObjectId(this._feeItemObjectId);
        if (targetItem == null || refinerItem == null || feeItem == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        if (!targetItem.canBeAugmented(activeChar)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        VariationFee fee = VariationUtils.getVariationFee(targetItem, refinerItem);
        if (fee == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        if (fee.getFeeItemId() != feeItem.getItemId()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        activeChar.sendPacket(new ExPutCommissionResultForVariationMake(this._feeItemObjectId, fee.getFeeItemCount()), SystemMsg.PRESS_THE_AUGMENT_BUTTON_TO_BEGIN);
    }
}

