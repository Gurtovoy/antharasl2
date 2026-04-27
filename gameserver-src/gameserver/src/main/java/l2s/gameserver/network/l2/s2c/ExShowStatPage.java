/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class ExShowStatPage
extends L2GameServerPacket {
    private final int _page;

    public ExShowStatPage(int page) {
        this._page = page;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._page);
    }
}

