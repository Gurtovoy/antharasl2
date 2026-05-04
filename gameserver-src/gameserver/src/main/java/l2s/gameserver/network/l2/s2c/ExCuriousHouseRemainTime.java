package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExCuriousHouseRemainTime
extends L2GameServerPacket {
    private int _time;

    public ExCuriousHouseRemainTime(int time) {
        this._time = time;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._time);
    }
}

