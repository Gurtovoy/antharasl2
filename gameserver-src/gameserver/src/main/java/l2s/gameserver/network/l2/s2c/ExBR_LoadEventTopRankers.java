package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBR_LoadEventTopRankers
extends L2GameServerPacket {
    private int _eventId;
    private int _day;
    private int _count;
    private int _bestScore;
    private int _myScore;

    public ExBR_LoadEventTopRankers(int eventId, int day, int count, int bestScore, int myScore) {
        this._eventId = eventId;
        this._day = day;
        this._count = count;
        this._bestScore = bestScore;
        this._myScore = myScore;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._eventId);
        this.writeD(this._day);
        this.writeD(this._count);
        this.writeD(this._bestScore);
        this.writeD(this._myScore);
    }
}

