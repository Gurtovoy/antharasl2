/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.net.HostInfo
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.GameServerManager;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.authserver.network.gamecomm.as2gs.AuthResponse;
import l2s.authserver.network.gamecomm.as2gs.LoginServerFail;
import l2s.commons.net.HostInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthRequest
extends ReceivablePacket {
    private static final Logger _log = LoggerFactory.getLogger(AuthRequest.class);
    private int _protocolVersion;
    private HostInfo[] _hosts;
    private int _serverType;
    private int _ageLimit;
    private boolean _gmOnly;
    private boolean _brackets;
    private boolean _pvp;
    private int _maxOnline;

    @Override
    protected boolean readImpl() {
        this._protocolVersion = this.readD();
        if (this._protocolVersion != 4) {
            return true;
        }
        this._serverType = this.readD();
        this._ageLimit = this.readD();
        this._gmOnly = this.readC() == 1;
        this._brackets = this.readC() == 1;
        this._pvp = this.readC() == 1;
        this._maxOnline = this.readD();
        int hostsCount = this.readC();
        this._hosts = new HostInfo[hostsCount];
        for (int i = 0; i < hostsCount; ++i) {
            int id = this.readC();
            String address = this.readS();
            int port = this.readH();
            String key = this.readS();
            int maskCount = this.readC();
            HostInfo host = new HostInfo(id, address, port, key);
            for (int m = 0; m < maskCount; ++m) {
                String subAddress = this.readS();
                byte[] subnetAddress = new byte[this.readD()];
                this.readB(subnetAddress);
                byte[] subnetMask = new byte[this.readD()];
                this.readB(subnetMask);
                host.addSubnet(subAddress, subnetAddress, subnetMask);
            }
            this._hosts[i] = host;
        }
        return true;
    }

    @Override
    protected void runImpl() {
        if (this._protocolVersion != 4) {
            _log.warn("Authserver and gameserver have different versions! Please update your servers.");
            this.sendPacket(new LoginServerFail("Authserver and gameserver have different versions! Please update your servers.", false));
            return;
        }
        GameServer gs = this.getGameServer();
        _log.info("Trying to register gameserver: IP[" + gs.getConnection().getIpAddress() + "]");
        for (HostInfo host : this._hosts) {
            int registerResult = GameServerManager.getInstance().registerGameServer(host, gs);
            if (registerResult == 0) {
                gs.addHost(host);
                continue;
            }
            if (registerResult == 1) {
                this.sendPacket(new LoginServerFail("Gameserver registration on ID[" + host.getId() + "] failed. Registered different keys!", false));
                this.sendPacket(new LoginServerFail("Set the same keys in authserver and gameserver, and restart them!", false));
                continue;
            }
            if (registerResult == 2) {
                this.sendPacket(new LoginServerFail("Gameserver registration on ID[" + host.getId() + "] failed. ID[" + host.getId() + "] is already in use!", false));
                this.sendPacket(new LoginServerFail("Free ID[" + host.getId() + "] or change to another ID, and restart your authserver or gameserver!", false));
                continue;
            }
            if (registerResult != 3) continue;
            this.sendPacket(new LoginServerFail("Gameserver registration on ID[" + host.getId() + "] failed. You have some errors!", false));
            this.sendPacket(new LoginServerFail("To solve the problem, contact the developer!", false));
        }
        if (gs.getHosts().length <= 0) {
            this.sendPacket(new LoginServerFail("Gameserver registration failed. All ID's is already in use!", true));
            _log.info("Gameserver registration failed.");
            return;
        }
        gs.setProtocol(this._protocolVersion);
        gs.setServerType(this._serverType);
        gs.setAgeLimit(this._ageLimit);
        gs.setGmOnly(this._gmOnly);
        gs.setShowingBrackets(this._brackets);
        gs.setPvp(this._pvp);
        gs.setMaxPlayers(this._maxOnline);
        gs.store();
        gs.setAuthed(true);
        gs.getConnection().startPingTask();
        _log.info("Gameserver registration successful.");
        this.sendPacket(new AuthResponse(gs));
    }
}

