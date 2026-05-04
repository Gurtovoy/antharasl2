package l2s.gameserver.config.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.net.HostInfo;
import l2s.gameserver.Config;

public final class HostsConfigHolder
extends AbstractHolder {
    private static final HostsConfigHolder _instance = new HostsConfigHolder();
    private HostInfo _authServerHost;
    private TIntObjectMap<HostInfo> _gameServerHosts = new TIntObjectHashMap();

    public static HostsConfigHolder getInstance() {
        return _instance;
    }

    public void setAuthServerHost(HostInfo host) {
        this._authServerHost = host;
    }

    public HostInfo getAuthServerHost() {
        return this._authServerHost;
    }

    public void addGameServerHost(HostInfo host) {
        if (this._gameServerHosts.containsKey(host.getId())) {
            this.warn("Error while loading gameserver host info! Host have dublicate id: " + host.getId());
            return;
        }
        if (this._gameServerHosts.isEmpty()) {
            Config.REQUEST_ID = host.getId();
            Config.EXTERNAL_HOSTNAME = host.getAddress();
            Config.PORT_GAME = host.getPort();
        }
        this._gameServerHosts.put(host.getId(), host);
    }

    public HostInfo[] getGameServerHosts() {
        return (HostInfo[])this._gameServerHosts.values(new HostInfo[this._gameServerHosts.size()]);
    }

    public void log() {
        this.info("=================================================");
        this.info("Authserver host info: IP[" + this.getAuthServerHost().getAddress() + "], PORT[" + this.getAuthServerHost().getPort() + "]");
        this.info("=================================================");
        this.info("Gameserver host info:");
        for (HostInfo host : this.getGameServerHosts()) {
            this.info("ID[" + host.getId() + "], ADDRESS[" + (host.getAddress() == null ? "NOT SPECIFIED" : host.getAddress()) + "], PORT[" + host.getPort() + "]");
        }
        this.info("=================================================");
    }

    public int size() {
        int size = this._gameServerHosts.size();
        if (this._authServerHost != null) {
            ++size;
        }
        return size;
    }

    public void clear() {
        this._authServerHost = null;
        this._gameServerHosts.clear();
    }
}

