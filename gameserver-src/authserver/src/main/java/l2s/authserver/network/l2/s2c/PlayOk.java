package l2s.authserver.network.l2.s2c;

import l2s.authserver.network.l2.SessionKey;
import l2s.authserver.network.l2.s2c.L2LoginServerPacket;

public final class PlayOk
extends L2LoginServerPacket {
    private int _playOk1;
    private int _playOk2;
    private final int _serverId;

    public PlayOk(SessionKey sessionKey, int serverId) {
        this._playOk1 = sessionKey.playOkID1;
        this._playOk2 = sessionKey.playOkID2;
        this._serverId = serverId;
    }

    @Override
    protected void writeImpl() {
        this.writeC(7);
        this.writeD(this._playOk1);
        this.writeD(this._playOk2);
        this.writeC(this._serverId);
    }
}

