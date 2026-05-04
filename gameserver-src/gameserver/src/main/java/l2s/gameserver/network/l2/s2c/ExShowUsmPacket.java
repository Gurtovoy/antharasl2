/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowUsmPacket
extends L2GameServerPacket {
    private int _usmVideoId;

    public ExShowUsmPacket(int usmVideoId) {
        this._usmVideoId = usmVideoId;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._usmVideoId);
    }
}

