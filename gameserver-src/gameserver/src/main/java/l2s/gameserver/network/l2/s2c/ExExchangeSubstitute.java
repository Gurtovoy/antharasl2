package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExExchangeSubstitute
extends L2GameServerPacket {
    public ExExchangeSubstitute(Player pl, Player pl2) {
    }

    @Override
    protected void writeImpl() {
        this.writeD(0);
        this.writeQ(3000000L);
        this.writeD(0);
    }
}

