package l2s.authserver.network.gamecomm.as2gs;

import l2s.authserver.accounts.Account;
import l2s.authserver.accounts.SessionManager;
import l2s.authserver.network.gamecomm.SendablePacket;
import l2s.authserver.network.l2.SessionKey;

public class PlayerAuthResponse
extends SendablePacket {
    private String login;
    private boolean authed;
    private int playOkID1;
    private int playOkID2;
    private int loginOkID1;
    private int loginOkID2;
    private int bonus;
    private int bonusExpire;
    private int points;
    private String hwid;
    private long phoneNumber;

    public PlayerAuthResponse(SessionManager.Session session, SessionKey gameSkey, boolean authed) {
        Account account = session.getAccount();
        this.login = account.getLogin();
        this.authed = authed;
        if (authed) {
            this.playOkID1 = gameSkey.playOkID1;
            this.playOkID2 = gameSkey.playOkID2;
            this.loginOkID1 = gameSkey.loginOkID1;
            this.loginOkID2 = gameSkey.loginOkID2;
            this.bonus = account.getBonus();
            this.bonusExpire = account.getBonusExpire();
            this.points = account.getPoints();
            this.hwid = account.getAllowedHwid();
            this.phoneNumber = account.getPhoneNumber();
        }
    }

    public PlayerAuthResponse(String account) {
        this.login = account;
        this.authed = false;
    }

    @Override
    protected void writeImpl() {
        this.writeC(2);
        this.writeS(this.login);
        this.writeC(this.authed ? 1 : 0);
        if (this.authed) {
            this.writeD(this.playOkID1);
            this.writeD(this.playOkID2);
            this.writeD(this.loginOkID1);
            this.writeD(this.loginOkID2);
            this.writeD(this.bonus);
            this.writeD(this.bonusExpire);
            this.writeD(this.points);
            this.writeS(this.hwid);
            this.writeQ(this.phoneNumber);
        }
    }
}

