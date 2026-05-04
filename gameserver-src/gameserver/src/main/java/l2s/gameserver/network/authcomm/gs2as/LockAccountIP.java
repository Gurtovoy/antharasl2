package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class LockAccountIP
extends SendablePacket {
    String _account;
    String _IP;
    int _time;

    public LockAccountIP(String account, String IP, int time) {
        this._account = account;
        this._IP = IP;
        this._time = time;
    }

    @Override
    protected void writeImpl() {
        this.writeC(11);
        this.writeS(this._account);
        this.writeS(this._IP);
        this.writeD(this._time);
    }
}

