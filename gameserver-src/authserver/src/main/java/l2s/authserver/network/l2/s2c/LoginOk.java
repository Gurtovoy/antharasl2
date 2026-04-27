/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.l2.s2c;

import l2s.authserver.network.l2.SessionKey;
import l2s.authserver.network.l2.s2c.L2LoginServerPacket;

public final class LoginOk
extends L2LoginServerPacket {
    private int _loginOk1;
    private int _loginOk2;

    public LoginOk(SessionKey sessionKey) {
        this._loginOk1 = sessionKey.loginOkID1;
        this._loginOk2 = sessionKey.loginOkID2;
    }

    @Override
    protected void writeImpl() {
        this.writeC(3);
        this.writeD(this._loginOk1);
        this.writeD(this._loginOk2);
        this.writeB(new byte[8]);
        this.writeD(1002);
        this.writeH(60872);
        this.writeC(35);
        this.writeC(6);
        this.writeB(new byte[28]);
    }
}

