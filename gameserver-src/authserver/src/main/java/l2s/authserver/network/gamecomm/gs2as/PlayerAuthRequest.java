/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.accounts.SessionManager;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.authserver.network.gamecomm.as2gs.PlayerAuthResponse;
import l2s.authserver.network.l2.SessionKey;

public class PlayerAuthRequest
extends ReceivablePacket {
    private String account;
    private int playOkId1;
    private int playOkId2;
    private int loginOkId1;
    private int loginOkId2;

    @Override
    protected boolean readImpl() {
        this.account = this.readS();
        this.playOkId1 = this.readD();
        this.playOkId2 = this.readD();
        this.loginOkId1 = this.readD();
        this.loginOkId2 = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        SessionKey skey = new SessionKey(this.loginOkId1, this.loginOkId2, this.playOkId1, this.playOkId2);
        SessionManager.Session session = SessionManager.getInstance().closeSession(skey);
        if (session == null || !session.getAccount().getLogin().equals(this.account)) {
            this.sendPacket(new PlayerAuthResponse(this.account));
            return;
        }
        this.sendPacket(new PlayerAuthResponse(session, skey, session.getSessionKey().equals(skey)));
    }
}

