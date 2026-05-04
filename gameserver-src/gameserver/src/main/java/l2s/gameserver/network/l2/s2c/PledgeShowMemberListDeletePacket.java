/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeShowMemberListDeletePacket
extends L2GameServerPacket {
    private String _player;

    public PledgeShowMemberListDeletePacket(String playerName) {
        this._player = playerName;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._player);
    }
}

