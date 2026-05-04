package l2s.authserver.network.gamecomm.as2gs;

import l2s.authserver.network.gamecomm.SendablePacket;

public class GetAccountInfo
extends SendablePacket {
    private String _name;

    public GetAccountInfo(String name) {
        this._name = name;
    }

    @Override
    protected void writeImpl() {
        this.writeC(4);
        this.writeS(this._name);
    }
}

