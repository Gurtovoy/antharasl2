package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExUnionPoint
extends L2GameServerPacket {
    private final int _clanId;

    public ExUnionPoint(int clanId) {
        this._clanId = clanId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._clanId);
    }
}

