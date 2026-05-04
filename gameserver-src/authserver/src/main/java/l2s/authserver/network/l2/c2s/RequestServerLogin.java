package l2s.authserver.network.l2.c2s;

import l2s.authserver.Config;
import l2s.authserver.GameServerManager;
import l2s.authserver.accounts.Account;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.SessionKey;
import l2s.authserver.network.l2.c2s.L2LoginClientPacket;
import l2s.authserver.network.l2.s2c.PlayFail;
import l2s.authserver.network.l2.s2c.PlayOk;

public class RequestServerLogin
extends L2LoginClientPacket {
    private int _loginOkID1;
    private int _loginOkID2;
    private int _serverId;

    @Override
    protected boolean readImpl() {
        this._loginOkID1 = this.readD();
        this._loginOkID2 = this.readD();
        this._serverId = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        L2LoginClient client = (L2LoginClient)this.getClient();
        if (!client.isPasswordCorrect()) {
            client.close(PlayFail.REASON_USER_OR_PASS_WRONG);
            return;
        }
        SessionKey skey = client.getSessionKey();
        if (skey == null || Config.SHOW_LICENCE && !skey.checkLoginPair(this._loginOkID1, this._loginOkID2)) {
            client.close(PlayFail.REASON_ACCESS_FAILED);
            return;
        }
        Account account = client.getAccount();
        GameServer gs = GameServerManager.getInstance().getGameServerById(this._serverId);
        if (gs == null || !gs.isAuthed()) {
            client.close(PlayFail.REASON_ACCESS_FAILED);
            return;
        }
        if (gs.isGmOnly() && account.getAccessLevel() < 100) {
            client.close(PlayFail.REASON_SERVER_MAINTENANCE);
            return;
        }
        if (gs.getOnline() >= gs.getMaxPlayers() && account.getAccessLevel() < 50) {
            client.close(PlayFail.REASON_SERVER_OVERLOADED);
            return;
        }
        account.setLastServer(this._serverId);
        account.update();
        client.close(new PlayOk(skey, this._serverId));
    }
}

