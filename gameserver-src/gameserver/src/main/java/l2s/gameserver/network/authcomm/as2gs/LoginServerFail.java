/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.authcomm.as2gs;

import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LoginServerFail
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(LoginServerFail.class);
    private static final String[] REASONS = new String[]{"none", "IP banned", "IP reserved", "wrong hexid", "ID reserved", "no free ID", "not authed", "already logged in"};
    private String _reason;
    private boolean _restartConnection = true;

    @Override
    protected boolean readImpl() {
        int reasonId = this.readC();
        if (!this.getByteBuffer().hasRemaining()) {
            this._reason = "Authserver registration failed! Reason: " + REASONS[reasonId];
        } else {
            this._reason = this.readS();
            this._restartConnection = this.readC() > 0;
        }
        return true;
    }

    @Override
    protected void runImpl() {
        _log.warn(this._reason);
        if (this._restartConnection) {
            AuthServerCommunication.getInstance().restart();
        }
    }
}

