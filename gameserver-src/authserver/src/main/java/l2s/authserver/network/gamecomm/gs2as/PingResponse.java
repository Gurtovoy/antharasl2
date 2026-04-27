/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PingResponse
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(PingResponse.class);
    private long _serverTime;

    @Override
    protected boolean readImpl() {
        this._serverTime = this.readQ();
        return true;
    }

    @Override
    protected void runImpl() {
        GameServer gameServer = this.getGameServer();
        if (!gameServer.isAuthed()) {
            return;
        }
        gameServer.getConnection().onPingResponse();
        long diff = System.currentTimeMillis() - this._serverTime;
        if (Math.abs(diff) > 999L) {
            _log.warn("Gameserver IP[" + gameServer.getConnection().getIpAddress() + "]: time offset " + diff + " ms.");
        }
    }
}

