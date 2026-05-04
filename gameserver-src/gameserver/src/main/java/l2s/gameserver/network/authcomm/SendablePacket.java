package l2s.gameserver.network.authcomm;

import java.nio.ByteBuffer;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class SendablePacket
extends l2s.commons.net.nio.SendablePacket<AuthServerCommunication> {
    private static final Logger _log = LoggerFactory.getLogger(SendablePacket.class);

    public AuthServerCommunication getClient() {
        return AuthServerCommunication.getInstance();
    }

    protected ByteBuffer getByteBuffer() {
        return this.getClient().getWriteBuffer();
    }

    public boolean write() {
        try {
            this.writeImpl();
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
        return true;
    }

    protected abstract void writeImpl();
}

