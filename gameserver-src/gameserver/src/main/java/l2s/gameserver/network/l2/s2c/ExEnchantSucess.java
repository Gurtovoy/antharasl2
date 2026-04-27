/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class ExEnchantSucess
extends L2GameServerPacket {
    private final int _itemId;

    public ExEnchantSucess(int itemId) {
        this._itemId = itemId;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._itemId);
    }
}

