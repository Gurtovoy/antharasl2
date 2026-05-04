package l2s.authserver.network.gamecomm;

import java.nio.ByteBuffer;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.SendablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ReceivablePacket
extends l2s.commons.net.nio.ReceivablePacket<GameServer> {
    private static final Logger _log = LoggerFactory.getLogger(ReceivablePacket.class);
    protected GameServer _gs;
    protected ByteBuffer _buf;

    protected void setByteBuffer(ByteBuffer buf) {
        this._buf = buf;
    }

    protected ByteBuffer getByteBuffer() {
        return this._buf;
    }

    protected void setClient(GameServer gs) {
        this._gs = gs;
    }

    public GameServer getClient() {
        return this._gs;
    }

    public GameServer getGameServer() {
        return this.getClient();
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

    public void sendPacket(SendablePacket packet) {
        this.getGameServer().sendPacket(packet);
    }
}

