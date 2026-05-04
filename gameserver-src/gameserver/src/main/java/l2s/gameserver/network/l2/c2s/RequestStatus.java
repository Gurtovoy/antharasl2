package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.SendStatus;

public final class RequestStatus
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        ((GameClient)this.getClient()).close(new SendStatus());
    }
}

