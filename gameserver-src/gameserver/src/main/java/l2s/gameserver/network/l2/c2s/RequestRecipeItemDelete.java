/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.RecipeHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.RecipeBookItemListPacket;
import l2s.gameserver.templates.item.RecipeTemplate;

public class RequestRecipeItemDelete
extends L2GameClientPacket {
    private int _recipeId;

    @Override
    protected boolean readImpl() {
        this._recipeId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getPrivateStoreType() == 5) {
            activeChar.sendActionFailed();
            return;
        }
        RecipeTemplate recipe = RecipeHolder.getInstance().getRecipeByRecipeId(this._recipeId);
        if (recipe == null) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.unregisterRecipe(this._recipeId);
        activeChar.sendPacket((IBroadcastPacket)new RecipeBookItemListPacket(activeChar, !recipe.isCommon()));
    }
}

