/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.ReceivablePacket;

public class OnlineStatus
extends ReceivablePacket {
    private boolean _online;

    @Override
    protected boolean readImpl() {
        this._online = this.readC() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        GameServer gameServer = this.getGameServer();
        if (!gameServer.isAuthed()) {
            return;
        }
        gameServer.setOnline(this._online);
    }
}

