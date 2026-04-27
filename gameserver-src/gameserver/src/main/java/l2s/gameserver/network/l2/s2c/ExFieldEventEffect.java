/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFieldEventEffect
extends L2GameServerPacket {
    private final int _unk;

    public ExFieldEventEffect(int unk) {
        this._unk = unk;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._unk);
    }
}

