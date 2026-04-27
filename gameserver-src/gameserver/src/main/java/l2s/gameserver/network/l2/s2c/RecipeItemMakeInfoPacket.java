/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.RecipeTemplate;

public class RecipeItemMakeInfoPacket
extends L2GameServerPacket {
    private final int _id;
    private final boolean _isCommon;
    private final int _status;
    private final int _curMP;
    private final int _maxMP;

    public RecipeItemMakeInfoPacket(Player player, RecipeTemplate recipe, int status) {
        this._id = recipe.getId();
        this._isCommon = recipe.isCommon();
        this._status = status;
        this._curMP = (int)player.getCurrentMp();
        this._maxMP = player.getMaxMp();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._id);
        this.writeD(this._isCommon ? 1 : 0);
        this.writeD(this._curMP);
        this.writeD(this._maxMP);
        this.writeD(this._status);
        this.writeC(0);
    }
}

