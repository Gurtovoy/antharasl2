package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

class SuperCmdSummonCmd
extends L2GameClientPacket {
    private String _summonName;

    SuperCmdSummonCmd() {
    }

    @Override
    protected boolean readImpl() {
        this._summonName = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

