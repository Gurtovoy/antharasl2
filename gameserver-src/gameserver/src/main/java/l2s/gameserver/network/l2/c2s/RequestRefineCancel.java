/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExVariationCancelResult;
import l2s.gameserver.network.l2.s2c.ShortCutRegisterPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.NpcUtils;
import l2s.gameserver.utils.VariationUtils;

public final class RequestRefineCancel
extends L2GameClientPacket {
    private int _targetItemObjId;

    @Override
    protected boolean readImpl() {
        this._targetItemObjId = this.readD();
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
        if (!Config.BBS_AUGMENTATION_ENABLED && NpcUtils.canPassPacket(activeChar, this, new Object[0]) == null) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationCancelResult(0));
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationCancelResult(0));
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationCancelResult(0));
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationCancelResult(0));
            return;
        }
        ItemInstance targetItem = activeChar.getInventory().getItemByObjectId(this._targetItemObjId);
        if (targetItem == null || !targetItem.isAugmented()) {
            activeChar.sendPacket(new ExVariationCancelResult(0), SystemMsg.AUGMENTATION_REMOVAL_CAN_ONLY_BE_DONE_ON_AN_AUGMENTED_ITEM);
            return;
        }
        long price = VariationUtils.getRemovePrice(targetItem);
        if (price < 0L) {
            activeChar.sendPacket((IBroadcastPacket)new ExVariationCancelResult(0));
        }
        if (!activeChar.reduceAdena(price, true)) {
            activeChar.sendPacket(new ExVariationCancelResult(0), SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
            return;
        }
        VariationUtils.setVariation(activeChar, targetItem, 0, 0, 0);
        SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.AUGMENTATION_HAS_BEEN_SUCCESSFULLY_REMOVED_FROM_YOUR_S1);
        sm.addItemName(targetItem.getItemId());
        activeChar.sendPacket(new ExVariationCancelResult(1), sm);
        for (ShortCut sc : activeChar.getAllShortCuts()) {
            if (sc.getId() != targetItem.getObjectId() || sc.getType() != ShortCut.ShortCutType.ITEM) continue;
            activeChar.sendPacket((IBroadcastPacket)new ShortCutRegisterPacket(activeChar, sc));
        }
        activeChar.sendChanges();
    }
}

