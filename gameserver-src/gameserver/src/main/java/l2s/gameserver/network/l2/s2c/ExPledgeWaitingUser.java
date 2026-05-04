/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeWaitingUser
extends L2GameServerPacket {
    private final int _charId;
    private final String _desc;

    public ExPledgeWaitingUser(int charId, String desc) {
        this._charId = charId;
        this._desc = desc;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._charId);
        this.writeS(this._desc);
    }
}

