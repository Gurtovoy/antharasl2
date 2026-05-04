/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.RecipeShopSellListPacket;

public class RequestRecipeShopSellList
extends L2GameClientPacket {
    int _manufacturerId;

    @Override
    protected boolean readImpl() {
        this._manufacturerId = this.readD();
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
        Player manufacturer = (Player)activeChar.getVisibleObject(this._manufacturerId);
        if (manufacturer == null || manufacturer.getPrivateStoreType() != 5 || !manufacturer.checkInteractionDistance(activeChar)) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new RecipeShopSellListPacket(activeChar, manufacturer));
    }
}

