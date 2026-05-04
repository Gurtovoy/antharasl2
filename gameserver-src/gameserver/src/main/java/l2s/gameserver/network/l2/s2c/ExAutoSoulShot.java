/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.base.SoulShotType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAutoSoulShot
extends L2GameServerPacket {
    private final int _itemId;
    private final int _slotId;
    private final int _type;

    public ExAutoSoulShot(int itemId, int slotId, SoulShotType type) {
        this._itemId = itemId;
        this._slotId = slotId;
        this._type = type.ordinal();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._itemId);
        this.writeD(this._slotId);
        this.writeD(this._type);
    }
}

