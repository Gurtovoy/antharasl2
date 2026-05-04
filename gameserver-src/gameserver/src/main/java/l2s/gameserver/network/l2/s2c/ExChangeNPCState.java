package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExChangeNPCState
extends L2GameServerPacket {
    private int _objId;
    private int _state;

    public ExChangeNPCState(int objId, int state) {
        this._objId = objId;
        this._state = state;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objId);
        this.writeD(this._state);
    }
}

