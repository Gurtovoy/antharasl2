package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class JoinPartyPacket
extends L2GameServerPacket {
    public static final L2GameServerPacket SUCCESS = new JoinPartyPacket(1);
    public static final L2GameServerPacket FAIL = new JoinPartyPacket(0);
    private int _response;

    public JoinPartyPacket(int response) {
        this._response = response;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._response);
    }
}

