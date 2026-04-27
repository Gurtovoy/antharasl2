/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExEnchantTwoRemoveFail;
import l2s.gameserver.network.l2.s2c.ExEnchantTwoRemoveOK;

public class RequestNewEnchantRemoveTwo
extends L2GameClientPacket {
    private int _item2ObjectId;

    @Override
    protected boolean readImpl() {
        this._item2ObjectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        ItemInstance item2 = activeChar.getInventory().getItemByObjectId(this._item2ObjectId);
        if (item2 == null) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantTwoRemoveFail.STATIC);
            return;
        }
        if (activeChar.getSynthesisItem2() != item2) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantTwoRemoveFail.STATIC);
            return;
        }
        activeChar.setSynthesisItem2(null);
        activeChar.sendPacket((IBroadcastPacket)ExEnchantTwoRemoveOK.STATIC);
    }
}

