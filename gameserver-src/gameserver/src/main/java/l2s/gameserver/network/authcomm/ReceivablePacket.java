/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.authcomm;

import java.nio.ByteBuffer;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.SendablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ReceivablePacket
extends l2s.commons.net.nio.ReceivablePacket<AuthServerCommunication> {
    private static final Logger _log = LoggerFactory.getLogger(ReceivablePacket.class);

    public AuthServerCommunication getClient() {
        return AuthServerCommunication.getInstance();
    }

    protected ByteBuffer getByteBuffer() {
        return this.getClient().getReadBuffer();
    }

    public final boolean read() {
        try {
            return this.readImpl();
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
            return false;
        }
    }

    public final void run() {
        try {
            this.runImpl();
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
    }

    protected abstract boolean readImpl();

    protected abstract void runImpl();

    protected void sendPacket(SendablePacket sp) {
        this.getClient().sendPacket(sp);
    }
}

