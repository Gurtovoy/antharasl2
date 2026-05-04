package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.ReceivablePacket;

public class PlayerInGame
extends ReceivablePacket {
    private String account;

    @Override
    protected boolean readImpl() {
        this.account = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        GameServer gs = this.getGameServer();
        if (gs.isAuthed()) {
            gs.addAccount(this.account);
        }
    }
}

