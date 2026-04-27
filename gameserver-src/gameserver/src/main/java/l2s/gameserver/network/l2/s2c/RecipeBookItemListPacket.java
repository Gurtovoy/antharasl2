/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.RecipeTemplate;

public class RecipeBookItemListPacket
extends L2GameServerPacket {
    private Collection<RecipeTemplate> _recipes;
    private final boolean _isDwarvenCraft;
    private final int _currentMp;

    public RecipeBookItemListPacket(Player player, boolean isDwarvenCraft) {
        this._isDwarvenCraft = isDwarvenCraft;
        this._currentMp = (int)player.getCurrentMp();
        this._recipes = isDwarvenCraft ? player.getDwarvenRecipeBook() : player.getCommonRecipeBook();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._isDwarvenCraft ? 0 : 1);
        this.writeD(this._currentMp);
        this.writeD(this._recipes.size());
        for (RecipeTemplate recipe : this._recipes) {
            this.writeD(recipe.getId());
            this.writeD(1);
        }
    }
}

