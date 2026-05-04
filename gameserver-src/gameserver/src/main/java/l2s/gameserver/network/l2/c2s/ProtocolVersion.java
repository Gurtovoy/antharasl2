package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.SendStatus;
import l2s.gameserver.network.l2.s2c.VersionCheckPacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ProtocolVersion
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(ProtocolVersion.class);
    private int _version;

    @Override
    protected boolean readImpl() {
        this._version = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        if (this._version == -2) {
            ((GameClient)this._client).closeNow(false);
            return;
        }
        if (this._version == -3) {
            _log.info("Status request from IP : " + ((GameClient)this.getClient()).getIpAddr());
            ((GameClient)this.getClient()).close(new SendStatus());
            return;
        }
        if (!Config.AVAILABLE_PROTOCOL_REVISIONS.contains(this._version)) {
            _log.warn("Unknown protocol revision : " + this._version + ", client : " + this._client);
            ((GameClient)this.getClient()).close(new VersionCheckPacket(null));
            return;
        }
        ((GameClient)this.getClient()).setRevision(this._version);
        this.sendPacket((L2GameServerPacket)new VersionCheckPacket(((GameClient)this._client).enableCrypt()));
    }
}

