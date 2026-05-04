package l2s.gameserver.network.l2.c2s;

import java.nio.BufferUnderflowException;
import java.util.List;
import l2s.commons.net.nio.impl.ReceivablePacket;
import l2s.gameserver.GameServer;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class L2GameClientPacket
extends ReceivablePacket<GameClient> {
    private static final Logger _log = LoggerFactory.getLogger(L2GameClientPacket.class);

    public final boolean read() {
        if (!((GameClient)this.getClient()).checkFloodProtection(this.getFloodProtectorType(), this.getClass().getSimpleName())) {
            return false;
        }
        try {
            return this.readImpl();
        }
        catch (BufferUnderflowException e) {
            ((GameClient)this._client).onPacketReadFail();
            _log.error("Client: " + this._client + " - Failed reading: " + this.getType() + " - Server Version: " + GameServer.getInstance().getVersion().getRevisionNumber(), (Throwable)e);
        }
        catch (Exception e) {
            _log.error("Client: " + this._client + " - Failed reading: " + this.getType() + " - Server Version: " + GameServer.getInstance().getVersion().getRevisionNumber(), (Throwable)e);
        }
        return false;
    }

    protected abstract boolean readImpl() throws Exception;

    public final void run() {
        GameClient client = (GameClient)this.getClient();
        try {
            this.runImpl();
        }
        catch (Exception e) {
            _log.error("Client: " + (Object)((Object)client) + " - Failed running: " + this.getType() + " - Server Version: " + GameServer.getInstance().getVersion().getRevisionNumber(), (Throwable)e);
        }
    }

    protected abstract void runImpl() throws Exception;

    protected String readS(int len) {
        String ret = this.readS();
        return ret.length() > len ? ret.substring(0, len) : ret;
    }

    protected void sendPacket(L2GameServerPacket packet) {
        ((GameClient)this.getClient()).sendPacket(packet);
    }

    protected void sendPacket(L2GameServerPacket ... packets) {
        ((GameClient)this.getClient()).sendPacket(packets);
    }

    protected void sendPackets(List<L2GameServerPacket> packets) {
        ((GameClient)this.getClient()).sendPackets(packets);
    }

    public String getType() {
        return "[C] " + this.getClass().getSimpleName();
    }

    protected String getFloodProtectorType() {
        return this.getClass().getSimpleName();
    }
}

