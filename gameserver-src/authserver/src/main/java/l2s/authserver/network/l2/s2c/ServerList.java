package l2s.authserver.network.l2.s2c;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import l2s.authserver.GameServerManager;
import l2s.authserver.accounts.Account;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.GameServerConnection;
import l2s.authserver.network.l2.s2c.L2LoginServerPacket;
import l2s.commons.net.HostInfo;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class ServerList
extends L2LoginServerPacket {
    private static final Logger _log = LoggerFactory.getLogger(ServerList.class);
    private List<ServerData> _servers = new ArrayList<ServerData>();
    private int _lastServer;
    private int _paddedBytes;

    public ServerList(Account account) {
        this._lastServer = account.getLastServer();
        this._paddedBytes = 1;
        for (GameServer gs : GameServerManager.getInstance().getGameServers()) {
            for (HostInfo host : gs.getHosts()) {
                int[] deleteChars;
                int playerSize;
                InetAddress adress;
                try {
                    String adrStr = host.checkAddress(account.getLastIP());
                    if (adrStr == null) continue;
                    if (adrStr.equals("*")) {
                        GameServerConnection connection = gs.getConnection();
                        adrStr = connection != null ? connection.getIpAddress() : "0.0.0.0";
                    }
                    adress = InetAddress.getByName(adrStr);
                }
                catch (UnknownHostException e) {
                    _log.error("Error with gameserver host adress: " + e, (Throwable)e);
                    continue;
                }
                Pair<Integer, int[]> entry = account.getAccountInfo(host.getId());
                if (entry != null) {
                    playerSize = (Integer)entry.getKey();
                    deleteChars = (int[])entry.getValue();
                } else {
                    playerSize = 0;
                    deleteChars = ArrayUtils.EMPTY_INT_ARRAY;
                }
                this._paddedBytes += 3 + 4 * deleteChars.length;
                this._servers.add(new ServerData(host.getId(), adress, host.getPort(), gs.isPvp(), gs.isShowingBrackets(), gs.getServerType(), gs.getOnline(), gs.getMaxPlayers(), gs.isOnline(), playerSize, gs.getAgeLimit()));
            }
        }
    }

    @Override
    protected void writeImpl() {
        this.writeC(4);
        this.writeC(this._servers.size());
        this.writeC(this._lastServer);
        for (ServerData server : this._servers) {
            this.writeC(server.serverId);
            byte[] raw = server.adress.getAddress();
            this.writeC(raw[0] & 0xFF);
            this.writeC(raw[1] & 0xFF);
            this.writeC(raw[2] & 0xFF);
            this.writeC(raw[3] & 0xFF);
            this.writeD(server.port);
            this.writeC(server.ageLimit);
            this.writeC(server.pvp ? 1 : 0);
            this.writeH(server.online);
            this.writeH(server.maxPlayers);
            this.writeC(server.status ? 1 : 0);
            this.writeD(server.type);
            this.writeC(server.brackets ? 1 : 0);
        }
        this.writeH(this._paddedBytes);
        for (ServerData server : this._servers) {
            this.writeC(server.serverId);
            this.writeC(server.playerSize);
        }
    }

    private static class ServerData {
        int serverId;
        InetAddress adress;
        int port;
        int online;
        int maxPlayers;
        boolean status;
        boolean pvp;
        boolean brackets;
        int type;
        int ageLimit;
        int playerSize;

        ServerData(int serverId, InetAddress adress, int port, boolean pvp, boolean brackets, int type, int online, int maxPlayers, boolean status, int size, int ageLimit) {
            this.serverId = serverId;
            this.adress = adress;
            this.port = port;
            this.pvp = pvp;
            this.brackets = brackets;
            this.type = type;
            this.online = online;
            this.maxPlayers = maxPlayers;
            this.status = status;
            this.playerSize = size;
            this.ageLimit = ageLimit;
        }
    }
}

