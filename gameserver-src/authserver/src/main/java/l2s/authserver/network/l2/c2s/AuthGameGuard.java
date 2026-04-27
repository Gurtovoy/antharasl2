/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.l2.c2s;

import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.c2s.L2LoginClientPacket;
import l2s.authserver.network.l2.s2c.GGAuth;
import l2s.authserver.network.l2.s2c.LoginFail;

public class AuthGameGuard
extends L2LoginClientPacket {
    private int _sessionId;

    @Override
    protected boolean readImpl() {
        this._sessionId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        L2LoginClient client = (L2LoginClient)this.getClient();
        if (this._sessionId == 0 || this._sessionId == client.getSessionId()) {
            client.setState(L2LoginClient.LoginClientState.AUTHED_GG);
            client.sendPacket(new GGAuth(client.getSessionId()));
        } else {
            client.close(LoginFail.LoginFailReason.REASON_ACCESS_FAILED);
        }
    }
}

