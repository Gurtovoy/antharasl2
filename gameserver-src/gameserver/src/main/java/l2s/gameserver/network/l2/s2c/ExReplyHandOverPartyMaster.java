/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExReplyHandOverPartyMaster
extends L2GameServerPacket {
    public static final L2GameServerPacket TRUE = new ExReplyHandOverPartyMaster(true);
    public static final L2GameServerPacket FALSE = new ExReplyHandOverPartyMaster(false);
    private boolean _isLeader;

    public ExReplyHandOverPartyMaster(boolean leader) {
        this._isLeader = leader;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._isLeader);
    }
}

