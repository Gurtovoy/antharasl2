/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.l2.c2s;

import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.SessionKey;
import l2s.authserver.network.l2.c2s.L2LoginClientPacket;
import l2s.authserver.network.l2.s2c.LoginFail;
import l2s.authserver.network.l2.s2c.ServerList;

public class RequestServerList
extends L2LoginClientPacket {
    private int _loginOkID1;
    private int _loginOkID2;
    private int _unk;

    @Override
    protected boolean readImpl() {
        this._loginOkID1 = this.readD();
        this._loginOkID2 = this.readD();
        this._unk = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        L2LoginClient client = (L2LoginClient)this.getClient();
        SessionKey skey = client.getSessionKey();
        if (skey == null || !skey.checkLoginPair(this._loginOkID1, this._loginOkID2)) {
            client.close(LoginFail.LoginFailReason.REASON_ACCESS_FAILED);
            return;
        }
        client.sendPacket(new ServerList(client.getAccount()));
    }
}

