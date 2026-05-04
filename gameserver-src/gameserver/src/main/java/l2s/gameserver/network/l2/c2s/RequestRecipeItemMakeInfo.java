/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.RecipeHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.RecipeItemMakeInfoPacket;
import l2s.gameserver.templates.item.RecipeTemplate;

public class RequestRecipeItemMakeInfo
extends L2GameClientPacket {
    private int _id;

    @Override
    protected boolean readImpl() {
        this._id = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        RecipeTemplate recipe = RecipeHolder.getInstance().getRecipeByRecipeId(this._id);
        if (recipe == null) {
            activeChar.sendActionFailed();
            return;
        }
        this.sendPacket((L2GameServerPacket)new RecipeItemMakeInfoPacket(activeChar, recipe, -1));
    }
}

