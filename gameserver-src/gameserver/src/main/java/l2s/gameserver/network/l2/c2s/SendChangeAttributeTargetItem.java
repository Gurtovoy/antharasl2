/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExChangeAttributeInfo;

public class SendChangeAttributeTargetItem
extends L2GameClientPacket {
    public int _crystalItemId;
    public int _itemObjId;

    @Override
    protected boolean readImpl() {
        this._crystalItemId = this.readD();
        this._itemObjId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._itemObjId);
        if (item == null || !item.isWeapon()) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExChangeAttributeInfo(this._crystalItemId, item));
    }
}

