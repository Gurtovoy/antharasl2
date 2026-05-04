package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExItemAuctionStatus
extends L2GameServerPacket {
    @Override
    protected final void writeImpl() {
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeH(0);
        this.writeD(0);
        this.writeC(0);
    }
}

