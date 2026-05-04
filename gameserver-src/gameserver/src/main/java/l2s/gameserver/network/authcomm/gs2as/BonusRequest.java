package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class BonusRequest
extends SendablePacket {
    private String account;
    private int bonus;
    private int bonusExpire;

    public BonusRequest(String account, int bonus, int bonusExpire) {
        this.account = account;
        this.bonus = bonus;
        this.bonusExpire = bonusExpire;
    }

    @Override
    protected void writeImpl() {
        this.writeC(16);
        this.writeS(this.account);
        this.writeD(this.bonus);
        this.writeD(this.bonusExpire);
    }
}

