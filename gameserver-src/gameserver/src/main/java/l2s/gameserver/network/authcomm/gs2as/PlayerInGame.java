package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class PlayerInGame
extends SendablePacket {
    private String account;

    public PlayerInGame(String account) {
        this.account = account;
    }

    @Override
    protected void writeImpl() {
        this.writeC(3);
        this.writeS(this.account);
    }
}

