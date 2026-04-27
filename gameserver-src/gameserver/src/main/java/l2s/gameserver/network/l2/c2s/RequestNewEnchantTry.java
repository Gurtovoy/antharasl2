/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.util.Rnd;
import l2s.gameserver.data.xml.holder.SynthesisDataHolder;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExEnchantFail;
import l2s.gameserver.network.l2.s2c.ExEnchantSucess;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.templates.item.support.SynthesisData;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestNewEnchantTry
extends L2GameClientPacket {
    private static final Logger LOGGER = LoggerFactory.getLogger(RequestNewEnchantTry.class);

    @Override
    protected boolean readImpl() {
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
        if (activeChar.isActionsDisabled()) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        if (activeChar.isFishing()) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        ItemInstance item1 = activeChar.getSynthesisItem1();
        if (item1 == null) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        ItemInstance item2 = activeChar.getSynthesisItem2();
        if (item2 == null) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        if (item1 == item2 && item1.getCount() <= 1L) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        SynthesisData data = null;
        for (SynthesisData d : SynthesisDataHolder.getInstance().getDatas()) {
            if (item1.getItemId() == d.getItem1Id() && item2.getItemId() == d.getItem2Id()) {
                data = d;
                break;
            }
            if (item1.getItemId() != d.getItem2Id() || item2.getItemId() != d.getItem1Id()) continue;
            data = d;
            break;
        }
        if (data == null) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        boolean locationAvailable = false;
        for (int locationId : data.getLocationIds()) {
            if (locationId != -1 && locationId != activeChar.getLocationId()) continue;
            locationAvailable = true;
            break;
        }
        if (!locationAvailable) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            return;
        }
        if (data.getChance() < 0.0) {
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
            LOGGER.warn("Chance in synthesis data ID1[" + data.getItem1Id() + "] ID2[" + data.getItem2Id() + "] not specified!");
            return;
        }
        PcInventory inventory = activeChar.getInventory();
        inventory.writeLock();
        try {
            if (inventory.getItemByObjectId(item1.getObjectId()) == null) {
                activeChar.setSynthesisItem1(null);
                activeChar.setSynthesisItem2(null);
                activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
                return;
            }
            if (inventory.getItemByObjectId(item2.getObjectId()) == null) {
                activeChar.setSynthesisItem1(null);
                activeChar.setSynthesisItem2(null);
                activeChar.sendPacket((IBroadcastPacket)ExEnchantFail.STATIC);
                return;
            }
            ItemFunctions.deleteItem((Playable)activeChar, item1, 1L, true);
            ItemFunctions.deleteItem((Playable)activeChar, item2, 1L, true);
            if (Rnd.chance((double)data.getChance())) {
                ItemData succeItemData = data.getSuccessItemData();
                ItemFunctions.addItem(activeChar, succeItemData.getId(), succeItemData.getCount(), true);
                activeChar.sendPacket((IBroadcastPacket)new ExEnchantSucess(succeItemData.getId()));
            } else {
                ItemData failItemData = data.getFailItemData();
                ItemFunctions.addItem(activeChar, failItemData.getId(), failItemData.getCount(), true);
                if (data.getResultEffecttype() == 1) {
                    activeChar.sendPacket((IBroadcastPacket)new ExEnchantSucess(failItemData.getId()));
                } else {
                    activeChar.sendPacket((IBroadcastPacket)new ExEnchantFail(item1.getItemId(), item2.getItemId()));
                }
            }
            activeChar.setSynthesisItem1(null);
            activeChar.setSynthesisItem2(null);
        }
        finally {
            inventory.writeUnlock();
        }
    }
}

