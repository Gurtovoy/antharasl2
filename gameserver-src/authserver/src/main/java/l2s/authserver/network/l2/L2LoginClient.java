package l2s.authserver.network.l2;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.security.interfaces.RSAPrivateKey;
import l2s.authserver.Config;
import l2s.authserver.accounts.Account;
import l2s.authserver.crypt.LoginCrypt;
import l2s.authserver.crypt.ScrambledKeyPair;
import l2s.authserver.network.l2.SessionKey;
import l2s.authserver.network.l2.s2c.AccountKicked;
import l2s.authserver.network.l2.s2c.L2LoginServerPacket;
import l2s.authserver.network.l2.s2c.LoginFail;
import l2s.commons.net.nio.impl.MMOClient;
import l2s.commons.net.nio.impl.MMOConnection;
import l2s.commons.net.nio.impl.SendablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class L2LoginClient
extends MMOClient<MMOConnection<L2LoginClient>> {
    private static final Logger _log = LoggerFactory.getLogger(L2LoginClient.class);
    private static final int PROTOCOL_VERSION = 50721;
    private LoginClientState _state = LoginClientState.CONNECTED;
    private LoginCrypt _loginCrypt;
    private ScrambledKeyPair _scrambledPair = Config.getScrambledRSAKeyPair();
    private byte[] _blowfishKey = Config.getBlowfishKey();
    private String _login;
    private SessionKey _skey;
    private Account _account;
    private String _ipAddr;
    private int _sessionId;
    private boolean _passwordCorrect;

    public L2LoginClient(MMOConnection<L2LoginClient> con) {
        super(con);
        this._loginCrypt = new LoginCrypt();
        this._loginCrypt.setKey(this._blowfishKey);
        this._sessionId = con.hashCode();
        this._ipAddr = this.getConnection().getSocket().getInetAddress().getHostAddress();
        this._passwordCorrect = false;
    }

    public boolean decrypt(ByteBuffer buf, int size) {
        boolean ret;
        try {
            ret = this._loginCrypt.decrypt(buf.array(), buf.position(), size);
        }
        catch (IOException e) {
            return false;
        }
        return ret;
    }

    public boolean encrypt(ByteBuffer buf, int size) {
        int offset = buf.position();
        try {
            size = this._loginCrypt.encrypt(buf.array(), offset, size);
        }
        catch (IOException e) {
            _log.error("", (Throwable)e);
            return false;
        }
        buf.position(offset + size);
        return true;
    }

    public LoginClientState getState() {
        return this._state;
    }

    public void setState(LoginClientState state) {
        this._state = state;
    }

    public byte[] getBlowfishKey() {
        return this._blowfishKey;
    }

    public byte[] getScrambledModulus() {
        return this._scrambledPair.getScrambledModulus();
    }

    public RSAPrivateKey getRSAPrivateKey() {
        return (RSAPrivateKey)this._scrambledPair.getKeyPair().getPrivate();
    }

    public String getLogin() {
        return this._login;
    }

    public void setLogin(String login) {
        this._login = login;
    }

    public Account getAccount() {
        return this._account;
    }

    public void setAccount(Account account) {
        this._account = account;
    }

    public SessionKey getSessionKey() {
        return this._skey;
    }

    public void setSessionKey(SessionKey skey) {
        this._skey = skey;
    }

    public void setSessionId(int val) {
        this._sessionId = val;
    }

    public int getSessionId() {
        return this._sessionId;
    }

    public void setPasswordCorrect(boolean val) {
        this._passwordCorrect = val;
    }

    public boolean isPasswordCorrect() {
        return this._passwordCorrect;
    }

    public void sendPacket(L2LoginServerPacket lsp) {
        if (this.isConnected()) {
            this.getConnection().sendPacket((SendablePacket)lsp);
        }
    }

    public void close(LoginFail.LoginFailReason reason) {
        if (this.isConnected()) {
            this.getConnection().close((SendablePacket)new LoginFail(reason));
        }
    }

    public void close(AccountKicked.AccountKickedReason reason) {
        if (this.isConnected()) {
            this.getConnection().close((SendablePacket)new AccountKicked(reason));
        }
    }

    public void close(L2LoginServerPacket lsp) {
        if (this.isConnected()) {
            this.getConnection().close((SendablePacket)lsp);
        }
    }

    public void onDisconnection() {
        this._state = LoginClientState.DISCONNECTED;
        this._skey = null;
        this._loginCrypt = null;
        this._scrambledPair = null;
        this._blowfishKey = null;
    }

    public String toString() {
        switch (this._state) {
            case AUTHED: {
                return "[ Account : " + this.getLogin() + " IP: " + this.getIpAddress() + "]";
            }
        }
        return "[ State : " + (Object)((Object)this.getState()) + " IP: " + this.getIpAddress() + "]";
    }

    public String getIpAddress() {
        return this._ipAddr;
    }

    protected void onForcedDisconnection() {
    }

    public int getProtocol() {
        return 50721;
    }

    public static enum LoginClientState {
        CONNECTED,
        AUTHED_GG,
        AUTHED,
        DISCONNECTED;

    }
}

