package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ExBR_LoadEventTopRankers;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestExBR_EventRankerList
extends L2GameClientPacket {
    private static final String _C__D0_7B_BREVENTRANKERLIST = "[C] D0:7B BrEventRankerList";
    private int _eventId;
    private int _day;
    private int _ranking;

    @Override
    protected boolean readImpl() {
        this._eventId = this.readD();
        this._day = this.readD();
        this._ranking = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        int count = 0;
        int bestScore = 0;
        int myScore = 0;
        ((GameClient)this.getClient()).sendPacket((L2GameServerPacket)new ExBR_LoadEventTopRankers(this._eventId, this._day, count, bestScore, myScore));
    }

    @Override
    public String getType() {
        return _C__D0_7B_BREVENTRANKERLIST;
    }
}

