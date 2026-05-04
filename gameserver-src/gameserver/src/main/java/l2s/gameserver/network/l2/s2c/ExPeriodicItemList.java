package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class ExPeriodicItemList
extends L2GameServerPacket {
    private final int _result;
    private final int _objectID;
    private final int _period;

    public ExPeriodicItemList(int result, int objectID, int period) {
        this._result = result;
        this._objectID = objectID;
        this._period = period;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
        this.writeD(this._objectID);
        this.writeD(this._period);
    }
}

