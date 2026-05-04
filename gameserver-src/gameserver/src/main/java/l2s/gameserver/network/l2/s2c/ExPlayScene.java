package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPlayScene
extends L2GameServerPacket {
    @Override
    protected void writeImpl() {
        this.writeD(0);
    }
}

