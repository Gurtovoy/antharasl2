/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFieldEventPoint
extends L2GameServerPacket {
    private final int _points;

    public ExFieldEventPoint(int points) {
        this._points = points;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._points);
    }
}

