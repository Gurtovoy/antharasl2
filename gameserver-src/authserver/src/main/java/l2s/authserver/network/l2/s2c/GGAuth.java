package l2s.authserver.network.l2.s2c;

import l2s.authserver.network.l2.s2c.L2LoginServerPacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class GGAuth
extends L2LoginServerPacket {
    static Logger _log = LoggerFactory.getLogger(GGAuth.class);
    public static int SKIP_GG_AUTH_REQUEST = 11;
    private int _response;

    public GGAuth(int response) {
        this._response = response;
    }

    @Override
    protected void writeImpl() {
        this.writeC(11);
        this.writeD(this._response);
        this.writeB(new byte[16]);
    }
}

