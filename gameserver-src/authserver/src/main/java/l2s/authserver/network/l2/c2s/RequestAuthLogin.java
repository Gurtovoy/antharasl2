package l2s.authserver.network.l2.c2s;

import javax.crypto.Cipher;
import l2s.authserver.AuthBanManager;
import l2s.authserver.Config;
import l2s.authserver.GameServerManager;
import l2s.authserver.IpBanManager;
import l2s.authserver.accounts.Account;
import l2s.authserver.accounts.SessionManager;
import l2s.authserver.crypt.PasswordHash;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.as2gs.GetAccountInfo;
import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.c2s.L2LoginClientPacket;
import l2s.authserver.network.l2.s2c.LoginFail;
import l2s.authserver.network.l2.s2c.LoginOk;
import l2s.authserver.network.l2.s2c.ServerList;
import l2s.authserver.utils.Log;
import l2s.commons.ban.BanBindType;

public class RequestAuthLogin
extends L2LoginClientPacket {
    private final byte[] _raw1 = new byte[128];
    private final byte[] _raw2 = new byte[128];
    private boolean _newAuthMethod = false;

    @Override
    protected boolean readImpl() {
        if (this._buf.remaining() >= this._raw1.length + this._raw2.length) {
            this._newAuthMethod = true;
            this.readB(this._raw1);
            this.readB(this._raw2);
        }
        if (this._buf.remaining() >= this._raw1.length) {
            this.readB(this._raw1);
            this.readD();
            this.readD();
            this.readD();
            this.readD();
            this.readD();
            this.readD();
            this.readH();
            this.readC();
        }
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        boolean passwordCorrect;
        L2LoginClient client = (L2LoginClient)this.getClient();
        byte[] decUser = null;
        byte[] decPass = null;
        try {
            Cipher rsaCipher = Cipher.getInstance("RSA/ECB/nopadding");
            rsaCipher.init(2, client.getRSAPrivateKey());
            decUser = rsaCipher.doFinal(this._raw1, 0, 128);
            if (this._newAuthMethod) {
                decPass = rsaCipher.doFinal(this._raw2, 0, this._raw2.length);
            }
        }
        catch (Exception e) {
            client.closeNow(true);
            return;
        }
        String user = null;
        String password = null;
        if (this._newAuthMethod) {
            user = new String(decUser, 78, 32).trim().toLowerCase();
            password = new String(decPass, 92, 16).trim();
        } else {
            user = new String(decUser, 94, 14).trim().toLowerCase();
            password = new String(decUser, 108, 16).trim();
        }
        int currentTime = (int)(System.currentTimeMillis() / 1000L);
        Account account = new Account(user);
        account.restore();
        String passwordHash = Config.DEFAULT_CRYPT.encrypt(password);
        if (account.getPasswordHash() == null) {
            if (Config.AUTO_CREATE_ACCOUNTS && user.matches(Config.ANAME_TEMPLATE) && password.matches(Config.APASSWD_TEMPLATE)) {
                account.setAllowedIP("");
                account.setAllowedHwid("");
                account.setPasswordHash(passwordHash);
                account.save();
            } else {
                client.close(LoginFail.LoginFailReason.REASON_USER_OR_PASS_WRONG);
                return;
            }
        }
        if (!(passwordCorrect = account.getPasswordHash().equals(passwordHash))) {
            for (PasswordHash c : Config.LEGACY_CRYPT) {
                if (!c.compare(password, account.getPasswordHash())) continue;
                passwordCorrect = true;
                account.setPasswordHash(passwordHash);
                break;
            }
        }
        if (!IpBanManager.getInstance().tryLogin(client.getIpAddress(), passwordCorrect)) {
            client.closeNow(false);
            return;
        }
        client.setPasswordCorrect(passwordCorrect);
        if (!Config.CHEAT_PASSWORD_CHECK && !passwordCorrect) {
            client.close(LoginFail.LoginFailReason.REASON_USER_OR_PASS_WRONG);
            return;
        }
        if (AuthBanManager.getInstance().isBanned(BanBindType.LOGIN, account.getLogin())) {
            client.close(LoginFail.LoginFailReason.REASON_ACCESS_FAILED);
            return;
        }
        if (AuthBanManager.getInstance().isBanned(BanBindType.IP, client.getIpAddress())) {
            client.close(LoginFail.LoginFailReason.REASON_ACCESS_FAILED);
            return;
        }
        if (!account.isAllowedIP(client.getIpAddress())) {
            client.close(LoginFail.LoginFailReason.REASON_ATTEMPTED_RESTRICTED_IP);
            return;
        }
        for (GameServer gs : GameServerManager.getInstance().getGameServers()) {
            if (!gs.isAuthed()) continue;
            gs.sendPacket(new GetAccountInfo(user));
        }
        account.setLastAccess(currentTime);
        account.setLastIP(client.getIpAddress());
        Log.LogAccount(account);
        SessionManager.Session session = SessionManager.getInstance().openSession(account);
        client.setAuthed(true);
        client.setLogin(user);
        client.setAccount(account);
        client.setSessionKey(session.getSessionKey());
        client.setState(L2LoginClient.LoginClientState.AUTHED);
        if (Config.SHOW_LICENCE) {
            client.sendPacket(new LoginOk(client.getSessionKey()));
        } else {
            client.sendPacket(new ServerList(client.getAccount()));
        }
    }
}

