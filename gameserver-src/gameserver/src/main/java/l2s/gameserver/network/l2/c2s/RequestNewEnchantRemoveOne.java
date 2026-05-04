/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExEnchantOneRemoveFail;
import l2s.gameserver.network.l2.s2c.ExEnchantOneRemoveOK;

public class RequestNewEnchantRemoveOne
extends L2GameClientPacket {
    private int _item1ObjectId;

    @Override
    protected boolean readImpl() {
        this._item1ObjectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        ItemInstance item1 = activeChar.getInventory().getItemByObjectId(this._item1ObjectId);
        if (item1 == null) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantOneRemoveFail.STATIC);
            return;
        }
        if (activeChar.getSynthesisItem1() != item1) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantOneRemoveFail.STATIC);
            return;
        }
        activeChar.setSynthesisItem1(null);
        activeChar.sendPacket((IBroadcastPacket)ExEnchantOneRemoveOK.STATIC);
    }
}

