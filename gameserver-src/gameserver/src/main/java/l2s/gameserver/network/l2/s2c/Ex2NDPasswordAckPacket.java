package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class Ex2NDPasswordAckPacket
extends L2GameServerPacket {
    public static final int SUCCESS = 0;
    public static final int WRONG_PATTERN = 1;
    private int _response;

    public Ex2NDPasswordAckPacket(int response) {
        this._response = response;
    }

    @Override
    protected void writeImpl() {
        this.writeC(0);
        this.writeD(this._response == 1 ? 1 : 0);
        this.writeD(0);
    }
}

