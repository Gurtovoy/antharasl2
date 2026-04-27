/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExRegistPartySubstitute
extends L2GameServerPacket {
    private final int _object;

    public ExRegistPartySubstitute(int obj) {
        this._object = obj;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._object);
        this.writeD(1);
    }
}

