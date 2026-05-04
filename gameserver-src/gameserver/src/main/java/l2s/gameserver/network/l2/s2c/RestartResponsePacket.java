package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RestartResponsePacket
extends L2GameServerPacket {
    public static final RestartResponsePacket OK = new RestartResponsePacket(1);
    public static final RestartResponsePacket FAIL = new RestartResponsePacket(0);
    private String _message = "bye";
    private int _param;

    public RestartResponsePacket(int param) {
        this._param = param;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._param);
        this.writeS(this._message);
    }
}

