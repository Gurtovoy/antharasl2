package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ExRaidServerInfo;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestRaidServerInfo
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        this.sendPacket((L2GameServerPacket)new ExRaidServerInfo());
    }
}

