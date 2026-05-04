package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class ChangePhoneNumber
extends SendablePacket {
    private final String _account;
    private final long _phoneNumber;

    public ChangePhoneNumber(String account, long phoneNumber) {
        this._account = account;
        this._phoneNumber = phoneNumber;
    }

    @Override
    protected void writeImpl() {
        this.writeC(12);
        this.writeS(this._account);
        this.writeQ(this._phoneNumber);
    }
}

