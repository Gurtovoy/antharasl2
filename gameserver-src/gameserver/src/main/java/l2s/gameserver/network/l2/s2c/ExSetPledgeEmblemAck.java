package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExSetPledgeEmblemAck
extends L2GameServerPacket {
    private final int _part;

    public ExSetPledgeEmblemAck(int part) {
        this._part = part;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._part);
    }
}

