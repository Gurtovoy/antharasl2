/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class FriendAddRequest
extends L2GameServerPacket {
    private String _requestorName;

    public FriendAddRequest(String requestorName) {
        this._requestorName = requestorName;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(0);
        this.writeS(this._requestorName);
    }
}

