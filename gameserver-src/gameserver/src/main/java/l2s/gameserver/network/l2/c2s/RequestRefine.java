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
import l2s.gameserver.network.l2.s2c.ExVariationResult;
import l2s.gameserver.templates.item.support.variation.VariationFee;
import l2s.gameserver.utils.NpcUtils;
import l2s.gameserver.utils.VariationUtils;

public final class RequestRefine
extends L2GameClientPacket {
    private int _targetItemObjId;
    private int _refinerItemObjId;
    private int _feeItemObjId;
    private long _feeItemCount;

    @Override
    protected boolean readImpl() {
        this._targetItemObjId = this.readD();
        this._refinerItemObjId = this.readD();
        this._feeItemObjId = this.readD();
        this._feeItemCount = this.readQ();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._feeItemCount < 1L) {
            return;
        }
        if (!Config.ALLOW_AUGMENTATION) {
            activeChar.sendActionFailed();
            return;
        }
        if (!Config.BBS_AUGMENTATION_ENABLED && NpcUtils.canPassPacket(activeChar, this, new Object[0]) == null) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationResult(0, 0, 0));
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationResult(0, 0, 0));
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationResult(0, 0, 0));
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationResult(0, 0, 0));
            return;
        }
        ItemInstance targetItem = activeChar.getInventory().getItemByObjectId(this._targetItemObjId);
        ItemInstance refinerItem = activeChar.getInventory().getItemByObjectId(this._refinerItemObjId);
        ItemInstance feeItem = activeChar.getInventory().getItemByObjectId(this._feeItemObjId);
        if (targetItem == null || refinerItem == null || feeItem == null || activeChar.getLevel() < 46) {
            activeChar.sendPacket(new ExVariationResult(0, 0, 0), SystemMsg.AUGMENTATION_FAILED_DUE_TO_INAPPROPRIATE_CONDITIONS);
            return;
        }
        VariationFee fee = VariationUtils.getVariationFee(targetItem, refinerItem);
        if (fee == null) {
            activeChar.sendPacket(new ExVariationResult(0, 0, 0), SystemMsg.AUGMENTATION_FAILED_DUE_TO_INAPPROPRIATE_CONDITIONS);
            return;
        }
        if (VariationUtils.tryAugmentItem(activeChar, targetItem, refinerItem, feeItem, fee.getFeeItemCount())) {
            activeChar.sendPacket(new ExVariationResult(targetItem.getVariation1Id(), targetItem.getVariation2Id(), 1), SystemMsg.THE_ITEM_WAS_SUCCESSFULLY_AUGMENTED);
        } else {
            activeChar.sendPacket(new ExVariationResult(0, 0, 0), SystemMsg.AUGMENTATION_FAILED_DUE_TO_INAPPROPRIATE_CONDITIONS);
        }
    }
}

