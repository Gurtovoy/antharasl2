/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AskJoinPledgePacket
extends L2GameServerPacket {
    private int _requestorId;
    private String _pledgeName;

    public AskJoinPledgePacket(int requestorId, String pledgeName) {
        this._requestorId = requestorId;
        this._pledgeName = pledgeName;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._requestorId);
        this.writeS("");
        this.writeS(this._pledgeName);
        this.writeD(0);
        this.writeS("");
    }
}

