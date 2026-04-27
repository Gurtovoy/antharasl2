/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExRotation
extends L2GameServerPacket {
    private int _charObjId;
    private int _degree;

    public ExRotation(int charId, int degree) {
        this._charObjId = charId;
        this._degree = degree;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._charObjId);
        this.writeD(this._degree);
    }
}

