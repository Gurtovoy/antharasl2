/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ShowXMasSeal
extends L2GameServerPacket {
    private int _item;

    public ShowXMasSeal(int item) {
        this._item = item;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._item);
    }
}

