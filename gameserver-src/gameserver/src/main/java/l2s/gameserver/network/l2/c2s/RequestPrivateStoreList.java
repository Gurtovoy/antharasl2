package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestPrivateStoreList
extends L2GameClientPacket {
    private int unk;

    @Override
    protected boolean readImpl() {
        this.unk = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

