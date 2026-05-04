/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ManufactureItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.RecipeShopItemInfoPacket;

public class RequestRecipeShopMakeInfo
extends L2GameClientPacket {
    private int _manufacturerId;
    private int _recipeId;

    @Override
    protected boolean readImpl() {
        this._manufacturerId = this.readD();
        this._recipeId = this.readD();
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
        long price = -1L;
        for (ManufactureItem i : manufacturer.getCreateList().values()) {
            if (i.getRecipeId() != this._recipeId) continue;
            price = i.getCost();
            break;
        }
        if (price == -1L) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new RecipeShopItemInfoPacket(activeChar, manufacturer, this._recipeId, price, -1));
    }
}

