/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExResponseShowContents
extends L2GameServerPacket {
    private final String _contents;

    public ExResponseShowContents(String contents) {
        this._contents = contents;
    }

    @Override
    protected void writeImpl() {
        this.writeS(this._contents);
    }
}

