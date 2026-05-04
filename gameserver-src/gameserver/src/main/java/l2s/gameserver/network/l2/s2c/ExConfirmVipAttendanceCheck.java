package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExConfirmVipAttendanceCheck
extends L2GameServerPacket {
    private final boolean _success;
    private final int _receivedIndex;

    public ExConfirmVipAttendanceCheck(boolean success, int receivedIndex) {
        this._success = success;
        this._receivedIndex = receivedIndex;
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._success);
        this.writeC(this._receivedIndex);
        this.writeD(0);
        this.writeD(0);
    }
}

