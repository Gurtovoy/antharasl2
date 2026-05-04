/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.authcomm.as2gs;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import l2s.gameserver.network.authcomm.gs2as.OnlineStatus;
import l2s.gameserver.network.authcomm.gs2as.PlayerInGame;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthResponse
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(AuthResponse.class);
    private List<ServerInfo> _servers;

    @Override
    protected boolean readImpl() {
        int serverId = this.readC();
        String serverName = this.readS();
        if (!this.getByteBuffer().hasRemaining()) {
            this._servers = new ArrayList<ServerInfo>(1);
            this._servers.add(new ServerInfo(serverId, serverName));
        } else {
            int serversCount = this.readC();
            this._servers = new ArrayList<ServerInfo>(serversCount);
            for (int i = 0; i < serversCount; ++i) {
                this._servers.add(new ServerInfo(this.readC(), this.readS()));
            }
        }
        return true;
    }

    @Override
    protected void runImpl() {
        String[] accounts;
        for (ServerInfo info : this._servers) {
            _log.info("Registered on authserver as " + info.getId() + " [" + info.getName() + "]");
        }
        this.sendPacket(new OnlineStatus(true));
        for (String account : accounts = AuthServerCommunication.getInstance().getAccounts()) {
            this.sendPacket(new PlayerInGame(account));
        }
    }

    private static class ServerInfo {
        private final int _id;
        private final String _name;

        public ServerInfo(int id, String name) {
            this._id = id;
            this._name = name;
        }

        public int getId() {
            return this._id;
        }

        public String getName() {
            return this._name;
        }
    }
}

