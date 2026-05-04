package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class NotifyStartMiniGame
extends L2GameClientPacket {
    @Override
    protected void runImpl() {
    }

    @Override
    protected boolean readImpl() {
        return true;
    }
}

