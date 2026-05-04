package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AskJoinAlliancePacket
extends L2GameServerPacket {
    private String _requestorName;
    private String _requestorAllyName;
    private int _requestorId;

    public AskJoinAlliancePacket(int requestorId, String requestorName, String requestorAllyName) {
        this._requestorName = requestorName;
        this._requestorAllyName = requestorAllyName;
        this._requestorId = requestorId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._requestorId);
        this.writeS(this._requestorName);
        this.writeS("");
        this.writeS(this._requestorAllyName);
    }
}

