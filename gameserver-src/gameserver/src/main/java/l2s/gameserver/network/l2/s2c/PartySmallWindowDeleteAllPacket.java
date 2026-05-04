package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PartySmallWindowDeleteAllPacket
extends L2GameServerPacket {
    public static final L2GameServerPacket STATIC = new PartySmallWindowDeleteAllPacket();

    @Override
    protected final void writeImpl() {
    }
}

