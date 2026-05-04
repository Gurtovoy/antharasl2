package l2s.gameserver.network.l2.c2s;

import java.util.List;
import l2s.gameserver.data.xml.holder.EnsoulHolder;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExEnSoulExtractionResult;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.templates.item.support.Ensoul;
import l2s.gameserver.templates.item.support.EnsoulFee;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.NpcUtils;

public class RequestTryEnSoulExtraction
extends L2GameClientPacket {
    private int _itemObjectId;
    private int _ensoulType;
    private int _ensoulId;

    @Override
    protected boolean readImpl() {
        this._itemObjectId = this.readD();
        this._ensoulType = this.readC();
        this._ensoulId = this.readC();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (NpcUtils.canPassPacket(activeChar, this, new Object[0]) == null) {
            activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
            return;
        }
        activeChar.getInventory().writeLock();
        try {
            ItemInstance targetItem = activeChar.getInventory().getItemByObjectId(this._itemObjectId);
            if (targetItem == null) {
                activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
                return;
            }
            Ensoul ensoul = targetItem.getEnsoul(this._ensoulType, this._ensoulId);
            if (ensoul == null) {
                activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
                return;
            }
            int extractionItemId = ensoul.getExtractionItemId();
            if (extractionItemId <= 0) {
                activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
                return;
            }
            EnsoulFee ensoulFee = EnsoulHolder.getInstance().getEnsoulFee(targetItem.getGrade());
            if (ensoulFee == null) {
                activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
                return;
            }
            EnsoulFee.EnsoulFeeInfo feeInfo = ensoulFee.getFeeInfo(this._ensoulType, this._ensoulId);
            if (feeInfo == null) {
                activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
                return;
            }
            List<EnsoulFee.EnsoulFeeItem> feeItems = feeInfo.getRemoveFee();
            for (EnsoulFee.EnsoulFeeItem feeItem : feeItems) {
                if (ItemFunctions.haveItem(activeChar, feeItem.getId(), feeItem.getCount())) continue;
                activeChar.sendPacket((IBroadcastPacket)ExEnSoulExtractionResult.FAIL);
                return;
            }
            for (EnsoulFee.EnsoulFeeItem feeItem : feeItems) {
                ItemFunctions.deleteItem((Playable)activeChar, feeItem.getId(), feeItem.getCount());
            }
            targetItem.removeEnsoul(this._ensoulType, this._ensoulId, true);
            activeChar.getInventory().refreshEquip(targetItem);
            ItemFunctions.addItem(activeChar, extractionItemId, 1L);
            activeChar.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(activeChar, targetItem));
            activeChar.sendPacket((IBroadcastPacket)new ExEnSoulExtractionResult(targetItem.getNormalEnsouls(), targetItem.getSpecialEnsouls()));
        }
        finally {
            activeChar.getInventory().writeUnlock();
        }
    }
}

