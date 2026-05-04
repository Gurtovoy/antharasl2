package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExNotifyBirthDay
extends L2GameServerPacket {
    public static final L2GameServerPacket STATIC = new ExNotifyBirthDay();

    @Override
    protected void writeImpl() {
        this.writeD(0);
    }
}

