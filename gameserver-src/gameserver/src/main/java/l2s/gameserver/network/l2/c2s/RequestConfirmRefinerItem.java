/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPutIntensiveResultForVariationMake;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.templates.item.support.variation.VariationFee;
import l2s.gameserver.utils.VariationUtils;

public class RequestConfirmRefinerItem
extends L2GameClientPacket {
    private int _targetItemObjId;
    private int _refinerItemObjId;

    @Override
    protected boolean readImpl() {
        this._targetItemObjId = this.readD();
        this._refinerItemObjId = this.readD();
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
        ItemInstance targetItem = activeChar.getInventory().getItemByObjectId(this._targetItemObjId);
        ItemInstance refinerItem = activeChar.getInventory().getItemByObjectId(this._refinerItemObjId);
        if (targetItem == null || refinerItem == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        if (!targetItem.canBeAugmented(activeChar)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        if (refinerItem.getTemplate().isBlocked(activeChar, refinerItem)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        VariationFee fee = VariationUtils.getVariationFee(targetItem, refinerItem);
        if (fee == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_SUITABLE_ITEM);
            return;
        }
        int feeItemId = fee.getFeeItemId();
        long feeCount = fee.getFeeItemCount();
        SystemMessage sm = new SystemMessage(1959).addNumber(feeCount).addItemName(feeItemId);
        activeChar.sendPacket(new ExPutIntensiveResultForVariationMake(this._refinerItemObjId, refinerItem.getItemId(), feeItemId, feeCount), sm);
    }
}

