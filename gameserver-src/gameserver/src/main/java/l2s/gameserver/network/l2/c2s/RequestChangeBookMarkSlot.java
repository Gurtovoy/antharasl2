package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestChangeBookMarkSlot
extends L2GameClientPacket {
    private int slot_old;
    private int slot_new;

    @Override
    protected boolean readImpl() {
        this.slot_old = this.readD();
        this.slot_new = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

