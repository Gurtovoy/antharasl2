/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AskJoinPartyPacket
extends L2GameServerPacket {
    private String _requestorName;
    private int _itemDistribution;

    public AskJoinPartyPacket(String requestorName, int itemDistribution) {
        this._requestorName = requestorName;
        this._itemDistribution = itemDistribution;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._requestorName);
        this.writeD(this._itemDistribution);
    }
}

