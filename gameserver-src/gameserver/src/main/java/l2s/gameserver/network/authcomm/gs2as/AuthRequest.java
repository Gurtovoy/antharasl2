/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.net.HostInfo
 *  l2s.commons.net.utils.Net
 */
package l2s.gameserver.network.authcomm.gs2as;

import java.util.Map;
import l2s.commons.net.HostInfo;
import l2s.commons.net.utils.Net;
import l2s.gameserver.Config;
import l2s.gameserver.GameServer;
import l2s.gameserver.config.xml.holder.HostsConfigHolder;
import l2s.gameserver.network.authcomm.SendablePacket;

public class AuthRequest
extends SendablePacket {
    @Override
    protected void writeImpl() {
        this.writeC(0);
        this.writeD(4);
        this.writeD(Config.AUTH_SERVER_SERVER_TYPE);
        this.writeD(Config.AUTH_SERVER_AGE_LIMIT);
        this.writeC(Config.AUTH_SERVER_GM_ONLY ? 1 : 0);
        this.writeC(Config.AUTH_SERVER_BRACKETS ? 1 : 0);
        this.writeC(Config.AUTH_SERVER_IS_PVP ? 1 : 0);
        this.writeD(GameServer.getInstance().getOnlineLimit());
        HostInfo[] hosts = HostsConfigHolder.getInstance().getGameServerHosts();
        this.writeC(hosts.length);
        for (HostInfo host : hosts) {
            this.writeC(host.getId());
            this.writeS(host.getAddress());
            this.writeH(host.getPort());
            this.writeS(host.getKey());
            this.writeC(host.getSubnets().size());
            for (Map.Entry m : host.getSubnets().entrySet()) {
                this.writeS((CharSequence)m.getValue());
                byte[] address = ((Net)m.getKey()).getAddress();
                this.writeD(address.length);
                this.writeB(address);
                byte[] mask = ((Net)m.getKey()).getMask();
                this.writeD(mask.length);
                this.writeB(mask);
            }
        }
    }
}

