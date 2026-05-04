/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.xml.holder.EnsoulHolder;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExEnsoulResult;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.templates.item.support.Ensoul;
import l2s.gameserver.templates.item.support.EnsoulFee;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.NpcUtils;

public class RequestItemEnsoul
extends L2GameClientPacket {
    private int _itemObjectId;
    private List<EnsoulInfo> _ensoulsInfo;

    @Override
    protected boolean readImpl() {
        this._itemObjectId = this.readD();
        int changesCount = this.readC();
        this._ensoulsInfo = new ArrayList<EnsoulInfo>(changesCount);
        for (int i = 0; i < changesCount; ++i) {
            EnsoulInfo info = new EnsoulInfo();
            info.type = this.readC();
            info.id = this.readC();
            info.itemObjectId = this.readD();
            info.ensoulId = this.readD();
            this._ensoulsInfo.add(info);
        }
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (NpcUtils.canPassPacket(activeChar, this, new Object[0]) == null) {
            activeChar.sendPacket((IBroadcastPacket)ExEnsoulResult.FAIL);
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendPacket((IBroadcastPacket)ExEnsoulResult.FAIL);
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)ExEnsoulResult.FAIL);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendPacket((IBroadcastPacket)ExEnsoulResult.FAIL);
            return;
        }
        activeChar.getInventory().writeLock();
        try {
            ItemInstance targetItem = activeChar.getInventory().getItemByObjectId(this._itemObjectId);
            if (targetItem == null) {
                activeChar.sendPacket((IBroadcastPacket)ExEnsoulResult.FAIL);
                return;
            }
            EnsoulFee ensoulFee = EnsoulHolder.getInstance().getEnsoulFee(targetItem.getGrade());
            boolean success = false;
            block4: for (EnsoulInfo info : this._ensoulsInfo) {
                EnsoulFee.EnsoulFeeInfo feeInfo;
                Ensoul ensoul;
                ItemInstance ensoulItem = activeChar.getInventory().getItemByObjectId(info.itemObjectId);
                if (ensoulItem == null || (ensoul = EnsoulHolder.getInstance().getEnsoul(info.ensoulId)) == null || ensoul.getItemId() != ensoulItem.getItemId() || !targetItem.canBeEnsoul(ensoul.getItemId())) continue;
                if (ensoulFee != null && (feeInfo = ensoulFee.getFeeInfo(info.type, info.id)) != null) {
                    List<EnsoulFee.EnsoulFeeItem> feeItems = !targetItem.containsEnsoul(info.type, info.id) ? feeInfo.getInsertFee() : feeInfo.getChangeFee();
                    for (EnsoulFee.EnsoulFeeItem feeItem : feeItems) {
                        if (ItemFunctions.haveItem(activeChar, feeItem.getId(), feeItem.getCount())) continue;
                        continue block4;
                    }
                    for (EnsoulFee.EnsoulFeeItem feeItem : feeItems) {
                        ItemFunctions.deleteItem((Playable)activeChar, feeItem.getId(), feeItem.getCount());
                    }
                }
                if (!ItemFunctions.deleteItem((Playable)activeChar, ensoulItem, 1L)) continue;
                targetItem.addEnsoul(info.type, info.id, ensoul, true);
                success = true;
            }
            activeChar.getInventory().refreshEquip(targetItem);
            if (success) {
                activeChar.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(activeChar, targetItem));
                activeChar.sendPacket((IBroadcastPacket)new ExEnsoulResult(targetItem.getNormalEnsouls(), targetItem.getSpecialEnsouls()));
            } else {
                activeChar.sendPacket((IBroadcastPacket)ExEnsoulResult.FAIL);
            }
        }
        finally {
            activeChar.getInventory().writeUnlock();
        }
    }

    private static class EnsoulInfo {
        public int type;
        public int id;
        public int itemObjectId;
        public int ensoulId;

        private EnsoulInfo() {
        }
    }
}

