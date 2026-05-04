/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.support.AppearanceStone;

public class ExChoose_Shape_Shifting_Item
extends L2GameServerPacket {
    private final int _type;
    private final int _targetType;
    private final int _itemId;

    public ExChoose_Shape_Shifting_Item(AppearanceStone stone) {
        this._type = stone.getType().ordinal();
        this._targetType = stone.getClientTargetType().ordinal();
        this._itemId = stone.getItemId();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._targetType);
        this.writeD(this._type);
        this.writeD(this._itemId);
    }
}

