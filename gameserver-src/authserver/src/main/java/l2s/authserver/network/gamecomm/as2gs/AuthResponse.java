/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.net.HostInfo
 */
package l2s.authserver.network.gamecomm.as2gs;

import l2s.authserver.Config;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.SendablePacket;
import l2s.commons.net.HostInfo;

public class AuthResponse
extends SendablePacket {
    private HostInfo[] _hosts;

    public AuthResponse(GameServer gs) {
        this._hosts = gs.getHosts();
    }

    @Override
    protected void writeImpl() {
        this.writeC(0);
        this.writeC(0);
        this.writeS("");
        this.writeC(this._hosts.length);
        for (HostInfo host : this._hosts) {
            this.writeC(host.getId());
            this.writeS(Config.SERVER_NAMES.get(host.getId()));
        }
    }
}

