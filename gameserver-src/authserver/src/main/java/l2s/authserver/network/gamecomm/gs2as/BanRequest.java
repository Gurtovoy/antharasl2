package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.AuthBanManager;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.commons.ban.BanBindType;

public class BanRequest
extends ReceivablePacket {
    private BanBindType bindType;
    private String bindValue;
    private int endTime;
    private String reason;

    @Override
    protected boolean readImpl() {
        try {
            this.bindType = BanBindType.VALUES[this.readC()];
        }
        catch (Exception e) {
            return false;
        }
        this.bindValue = this.readS();
        this.endTime = this.readD();
        this.reason = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        AuthBanManager.getInstance().giveBan(this.bindType, this.bindValue, this.endTime, this.reason);
    }
}

