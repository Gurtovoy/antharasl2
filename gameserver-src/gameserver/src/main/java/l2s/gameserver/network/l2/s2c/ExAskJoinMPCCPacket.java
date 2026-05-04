/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAskJoinMPCCPacket
extends L2GameServerPacket {
    private String _requestorName;

    public ExAskJoinMPCCPacket(String requestorName) {
        this._requestorName = requestorName;
    }

    @Override
    protected void writeImpl() {
        this.writeS(this._requestorName);
        this.writeD(0);
    }
}

