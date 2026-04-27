/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dao.JdbcEntityState
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemAttributes;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.ExBaseAttributeCancelResult;
import l2s.gameserver.network.l2.s2c.ExShowBaseAttributeCancelWindow;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;

public class RequestExRemoveItemAttribute
extends L2GameClientPacket {
    private int _objectId;
    private int _attributeId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._attributeId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isActionsDisabled() || activeChar.isInStoreMode() || activeChar.isInTrade()) {
            activeChar.sendActionFailed();
            return;
        }
        PcInventory inventory = activeChar.getInventory();
        ItemInstance itemToUnnchant = inventory.getItemByObjectId(this._objectId);
        if (itemToUnnchant == null) {
            activeChar.sendActionFailed();
            return;
        }
        ItemAttributes set = itemToUnnchant.getAttributes();
        Element element = Element.getElementById(this._attributeId);
        if (element == Element.NONE || set.getValue(element) <= 0) {
            activeChar.sendPacket(new ExBaseAttributeCancelResult(false, itemToUnnchant, element), ActionFailPacket.STATIC);
            return;
        }
        if (!activeChar.reduceAdena(ExShowBaseAttributeCancelWindow.getAttributeRemovePrice(itemToUnnchant), true)) {
            activeChar.sendPacket(new ExBaseAttributeCancelResult(false, itemToUnnchant, element), SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA, ActionFailPacket.STATIC);
            return;
        }
        itemToUnnchant.setAttributeElement(element, 0);
        itemToUnnchant.setJdbcState(JdbcEntityState.UPDATED);
        itemToUnnchant.update();
        activeChar.getInventory().refreshEquip(itemToUnnchant);
        activeChar.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(activeChar, itemToUnnchant));
        activeChar.sendPacket((IBroadcastPacket)new ExBaseAttributeCancelResult(true, itemToUnnchant, element));
        activeChar.updateStats();
    }
}

