package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestPCCafeCouponUse
extends L2GameClientPacket {
    private String _unknown;

    @Override
    protected boolean readImpl() {
        this._unknown = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

