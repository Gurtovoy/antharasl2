/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.security;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import l2s.gameserver.Config;
import l2s.gameserver.dao.AccountVariablesDAO;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.gs2as.ChangeAccessLevel;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.s2c.Ex2NDPasswordAckPacket;
import l2s.gameserver.network.l2.s2c.Ex2NDPasswordCheckPacket;
import l2s.gameserver.network.l2.s2c.Ex2NDPasswordVerifyPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SecondaryPasswordAuth {
    private static final Logger _log = LoggerFactory.getLogger(SecondaryPasswordAuth.class);
    private final GameClient _activeClient;
    private String _password;
    private int _wrongAttempts;
    private boolean _authed;
    private static final String VAR_PWD = "secauth_pwd";
    private static final String VAR_WTE = "secauth_wte";

    public SecondaryPasswordAuth(GameClient activeClient) {
        this._activeClient = activeClient;
        this._password = null;
        this._wrongAttempts = 0;
        this._authed = false;
        this.loadPassword();
    }

    private void loadPassword() {
        String accountName = this._activeClient.getLogin();
        String password = AccountVariablesDAO.getInstance().select(accountName, VAR_PWD);
        if (password != null) {
            this._password = password;
            String wrongAttempts = AccountVariablesDAO.getInstance().select(accountName, VAR_WTE);
            if (wrongAttempts != null) {
                this._wrongAttempts = Integer.parseInt(wrongAttempts);
            }
        }
    }

    public boolean savePassword(String password) {
        if (this.passwordExist()) {
            _log.warn("[SecondaryPasswordAuth]" + this._activeClient.getLogin() + " forced savePassword");
            this._activeClient.closeNow(false);
            return false;
        }
        if (!this.validatePassword(password)) {
            this._activeClient.sendPacket((L2GameServerPacket)new Ex2NDPasswordAckPacket(1));
            return false;
        }
        password = this.cryptPassword(password);
        String accountName = this._activeClient.getLogin();
        AccountVariablesDAO.getInstance().insert(accountName, VAR_PWD, password);
        this._password = password;
        return true;
    }

    public boolean insertWrongAttempt(int attempts) {
        String accountName = this._activeClient.getLogin();
        AccountVariablesDAO.getInstance().insert(accountName, VAR_WTE, Integer.toString(attempts));
        return true;
    }

    public boolean changePassword(String oldPassword, String newPassword) {
        if (!this.passwordExist()) {
            _log.warn("[SecondaryPasswordAuth]" + this._activeClient.getLogin() + " forced changePassword");
            this._activeClient.closeNow(false);
            return false;
        }
        if (!this.checkPassword(oldPassword, true)) {
            return false;
        }
        if (!this.validatePassword(newPassword)) {
            this._activeClient.sendPacket((L2GameServerPacket)new Ex2NDPasswordAckPacket(1));
            return false;
        }
        newPassword = this.cryptPassword(newPassword);
        String accountName = this._activeClient.getLogin();
        AccountVariablesDAO.getInstance().insert(accountName, VAR_PWD, newPassword);
        this._password = newPassword;
        this._authed = false;
        return true;
    }

    public boolean checkPassword(String password, boolean skipAuth) {
        if (!(password = this.cryptPassword(password)).equals(this._password)) {
            ++this._wrongAttempts;
            if (this._wrongAttempts < Config.EX_SECOND_AUTH_MAX_ATTEMPTS) {
                this._activeClient.sendPacket((L2GameServerPacket)new Ex2NDPasswordVerifyPacket(1, this._wrongAttempts));
                this.insertWrongAttempt(this._wrongAttempts);
                return false;
            }
            int banExpire = (int)(System.currentTimeMillis() / 1000L) + Config.EX_SECOND_AUTH_BAN_TIME * 60;
            int accessLvl = Config.EX_SECOND_AUTH_BAN_TIME > 0 ? 0 : -100;
            AuthServerCommunication.getInstance().sendPacket(new ChangeAccessLevel(this._activeClient.getLogin(), accessLvl, banExpire));
            _log.warn(this._activeClient.getLogin() + " - (" + this._activeClient.getIpAddr() + ") has inputted the wrong password " + this._wrongAttempts + " times in row.");
            this.insertWrongAttempt(0);
            this._activeClient.close(new Ex2NDPasswordVerifyPacket(2, Config.EX_SECOND_AUTH_MAX_ATTEMPTS));
            return false;
        }
        if (!skipAuth) {
            this._authed = true;
            this._activeClient.sendPacket((L2GameServerPacket)new Ex2NDPasswordVerifyPacket(0, this._wrongAttempts));
        }
        this.insertWrongAttempt(0);
        return true;
    }

    public boolean passwordExist() {
        return this._password != null;
    }

    public void openDialog() {
        if (this.passwordExist()) {
            this._activeClient.sendPacket((L2GameServerPacket)new Ex2NDPasswordCheckPacket(1));
        } else {
            this._activeClient.sendPacket((L2GameServerPacket)new Ex2NDPasswordCheckPacket(0));
        }
    }

    public boolean isAuthed() {
        return this._authed;
    }

    private String cryptPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA");
            byte[] raw = password.getBytes("UTF-8");
            byte[] hash = md.digest(raw);
            return Base64.getEncoder().encodeToString(hash);
        }
        catch (NoSuchAlgorithmException e) {
            _log.error("[SecondaryPasswordAuth] Unsupported Algorythm", (Throwable)e);
        }
        catch (UnsupportedEncodingException e) {
            _log.error("[SecondaryPasswordAuth] Unsupported Encoding", (Throwable)e);
        }
        return null;
    }

    private boolean validatePassword(String password) {
        if (!Strings.isDigit(password)) {
            return false;
        }
        if (password.length() < 6 || password.length() > 8) {
            return false;
        }
        this._wrongAttempts = 0;
        return true;
    }
}

