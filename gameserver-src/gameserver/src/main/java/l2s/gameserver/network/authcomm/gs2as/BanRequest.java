package l2s.gameserver.network.authcomm.gs2as;

import l2s.commons.ban.BanBindType;
import l2s.gameserver.network.authcomm.SendablePacket;

public class BanRequest
extends SendablePacket {
    private final BanBindType bindType;
    private final String bindValue;
    private final int endTime;
    private final String reason;

    public BanRequest(BanBindType bindType, String bindValue, int endTime, String reason) {
        this.bindType = bindType;
        this.bindValue = bindValue;
        this.endTime = endTime;
        this.reason = reason;
    }

    @Override
    protected void writeImpl() {
        this.writeC(19);
        this.writeC(this.bindType.ordinal());
        this.writeS(this.bindValue);
        this.writeD(this.endTime);
        this.writeS(this.reason);
    }
}

