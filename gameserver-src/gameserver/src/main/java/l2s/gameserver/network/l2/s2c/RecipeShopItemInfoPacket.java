/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RecipeShopItemInfoPacket
extends L2GameServerPacket {
    private int _recipeId;
    private int _shopId;
    private int _curMp;
    private int _maxMp;
    private int _success = -1;
    private long _price;

    public RecipeShopItemInfoPacket(Player activeChar, Player manufacturer, int recipeId, long price, int success) {
        this._recipeId = recipeId;
        this._shopId = manufacturer.getObjectId();
        this._price = price;
        this._success = success;
        this._curMp = (int)manufacturer.getCurrentMp();
        this._maxMp = manufacturer.getMaxMp();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._shopId);
        this.writeD(this._recipeId);
        this.writeD(this._curMp);
        this.writeD(this._maxMp);
        this.writeD(this._success);
        this.writeQ(this._price);
    }
}

