/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.ban.BanBindType;
import l2s.gameserver.Shutdown;
import l2s.gameserver.instancemanager.AuthBanManager;
import l2s.gameserver.instancemanager.GameBanManager;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.SessionKey;
import l2s.gameserver.network.authcomm.gs2as.PlayerAuthRequest;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.LoginResultPacket;
import l2s.gameserver.network.l2.s2c.ServerCloseSocketPacket;
import l2s.gameserver.utils.Language;

public class AuthLogin
extends L2GameClientPacket {
    private String _loginName;
    private int _playKey1;
    private int _playKey2;
    private int _loginKey1;
    private int _loginKey2;
    private int _lang;

    @Override
    protected boolean readImpl() {
        this._loginName = this.readS(32).toLowerCase();
        this._playKey2 = this.readD();
        this._playKey1 = this.readD();
        this._loginKey1 = this.readD();
        this._loginKey2 = this.readD();
        this._lang = this.readD();
        this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        GameClient client = (GameClient)this.getClient();
        SessionKey key = new SessionKey(this._loginKey1, this._loginKey2, this._playKey1, this._playKey2);
        client.setSessionId(key);
        client.setLoginName(this._loginName);
        client.setLanguage(Language.getLanguage(this._lang));
        if (Shutdown.getInstance().getMode() != -1 && Shutdown.getInstance().getSeconds() <= 15) {
            client.closeNow(false);
        } else {
            if (AuthServerCommunication.getInstance().isShutdown()) {
                client.close(LoginResultPacket.SYSTEM_ERROR_LOGIN_LATER);
                return;
            }
            if (GameBanManager.getInstance().isBanned(BanBindType.LOGIN, client.getLogin())) {
                client.close(LoginResultPacket.ACCESS_FAILED_TRY_LATER);
                return;
            }
            if (GameBanManager.getInstance().isBanned(BanBindType.IP, client.getIpAddr())) {
                client.close(LoginResultPacket.ACCESS_FAILED_TRY_LATER);
                return;
            }
            if (AuthBanManager.getInstance().isBanned(BanBindType.HWID, client.getHWID()) || GameBanManager.getInstance().isBanned(BanBindType.HWID, client.getHWID())) {
                client.close(LoginResultPacket.ACCESS_FAILED_TRY_LATER);
                return;
            }
            GameClient oldClient = AuthServerCommunication.getInstance().addWaitingClient(client);
            if (oldClient != null) {
                oldClient.close(ServerCloseSocketPacket.STATIC);
            }
            AuthServerCommunication.getInstance().sendPacket(new PlayerAuthRequest(client));
        }
    }
}

