/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.l2.s2c;

import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.s2c.L2LoginServerPacket;

public final class Init
extends L2LoginServerPacket {
    private int _sessionId;
    private byte[] _publicKey;
    private byte[] _blowfishKey;
    private final int _protocol;

    public Init(L2LoginClient client) {
        this(client.getScrambledModulus(), client.getBlowfishKey(), client.getSessionId(), client.getProtocol());
    }

    public Init(byte[] publickey, byte[] blowfishkey, int sessionId, int protocol) {
        this._sessionId = sessionId;
        this._publicKey = publickey;
        this._blowfishKey = blowfishkey;
        this._protocol = protocol;
    }

    @Override
    protected void writeImpl() {
        this.writeC(0);
        this.writeD(this._sessionId);
        this.writeD(this._protocol);
        this.writeB(this._publicKey);
        this.writeB(new byte[16]);
        this.writeB(this._blowfishKey);
        this.writeD(0);
    }
}

