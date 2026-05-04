package l2s.gameserver.network.l2.s2c;

import java.util.List;
import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.clansearch.ClanSearchPlayer;
import l2s.gameserver.model.clansearch.ClanSearchWaiterParams;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeDraftListSearch
extends L2GameServerPacket {
    private final List<ClanSearchPlayer> _waiters;

    public ExPledgeDraftListSearch(ClanSearchWaiterParams params) {
        this._waiters = ClanSearchManager.getInstance().listWaiters(params);
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._waiters.size());
        for (ClanSearchPlayer waiter : this._waiters) {
            this.writeD(waiter.getCharId());
            this.writeS(waiter.getName());
            this.writeD(waiter.getSearchType().ordinal());
            this.writeD(waiter.getClassId());
            this.writeD(waiter.getLevel());
        }
    }
}

