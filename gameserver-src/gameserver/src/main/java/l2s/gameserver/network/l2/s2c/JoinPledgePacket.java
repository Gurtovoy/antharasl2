package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class JoinPledgePacket
extends L2GameServerPacket {
    private int _pledgeId;

    public JoinPledgePacket(int pledgeId) {
        this._pledgeId = pledgeId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._pledgeId);
    }
}

