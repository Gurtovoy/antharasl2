package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;
import l2s.gameserver.network.l2.GameClient;

public class PlayerAuthRequest
extends SendablePacket {
    private String account;
    private int playOkID1;
    private int playOkID2;
    private int loginOkID1;
    private int loginOkID2;

    public PlayerAuthRequest(GameClient client) {
        this.account = client.getLogin();
        this.playOkID1 = client.getSessionKey().playOkID1;
        this.playOkID2 = client.getSessionKey().playOkID2;
        this.loginOkID1 = client.getSessionKey().loginOkID1;
        this.loginOkID2 = client.getSessionKey().loginOkID2;
    }

    @Override
    protected void writeImpl() {
        this.writeC(2);
        this.writeS(this.account);
        this.writeD(this.playOkID1);
        this.writeD(this.playOkID2);
        this.writeD(this.loginOkID1);
        this.writeD(this.loginOkID2);
    }
}

