package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestExEventMatchObserverEnd
extends L2GameClientPacket {
    private int unk;
    private int unk2;

    @Override
    protected boolean readImpl() {
        this.unk = this.readD();
        this.unk2 = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

