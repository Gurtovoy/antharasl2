/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExChangeNicknameNColor
extends L2GameServerPacket {
    private int _itemObjId;

    public ExChangeNicknameNColor(int itemObjId) {
        this._itemObjId = itemObjId;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._itemObjId);
    }
}

