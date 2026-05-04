package l2s.gameserver.network.l2.c2s;

import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExChangeAttributeFail;
import l2s.gameserver.network.l2.s2c.ExChangeAttributeOk;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestChangeAttributeItem
extends L2GameClientPacket {
    public int _consumeItemId;
    public int _itemObjId;
    public int _newElementId;

    @Override
    protected boolean readImpl() {
        this._consumeItemId = this.readD();
        this._itemObjId = this.readD();
        this._newElementId = this.readD();
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
        if (activeChar.getPrivateStoreType() != 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAN_NOT_CHANGE_THE_ATTRIBUTE_WHILE_OPERATING_A_PRIVATE_STORE_OR_PRIVATE_WORKSHOP);
            activeChar.sendPacket((IBroadcastPacket)ExChangeAttributeFail.STATIC);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendActionFailed();
            return;
        }
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._itemObjId);
        if (item == null || !item.isWeapon()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.UNABLE_TO_CHANCE_THE_ATTRIBUTE);
            activeChar.sendPacket((IBroadcastPacket)ExChangeAttributeFail.STATIC);
            return;
        }
        if (!activeChar.getInventory().destroyItemByItemId(this._consumeItemId, 1L)) {
            activeChar.sendActionFailed();
            return;
        }
        Element oldElement = item.getAttackElement();
        int elementVal = item.getAttributeElementValue(oldElement, false);
        item.setAttributeElement(oldElement, 0);
        Element newElement = Element.getElementById(this._newElementId);
        item.setAttributeElement(newElement, item.getAttributeElementValue(newElement, false) + elementVal);
        item.setJdbcState(JdbcEntityState.UPDATED);
        item.update();
        activeChar.getInventory().refreshEquip(item);
        SystemMessagePacket msg = new SystemMessagePacket(SystemMsg.IN_THE_ITEM_S1_ATTRIBUTE_S2_SUCCESSFULLY_CHANGED_TO_S3);
        msg.addName(item);
        msg.addElementName(oldElement);
        msg.addElementName(newElement);
        activeChar.sendPacket((IBroadcastPacket)msg);
        activeChar.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(activeChar, item));
        activeChar.sendPacket((IBroadcastPacket)ExChangeAttributeOk.STATIC);
        activeChar.updateStats();
    }
}

