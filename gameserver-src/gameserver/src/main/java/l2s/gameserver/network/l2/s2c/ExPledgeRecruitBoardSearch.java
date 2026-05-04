package l2s.gameserver.network.l2.s2c;

import java.util.List;
import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.clansearch.ClanSearchClan;
import l2s.gameserver.model.clansearch.ClanSearchParams;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.tables.ClanTable;

public class ExPledgeRecruitBoardSearch
extends L2GameServerPacket {
    private static final int PAGINATION_LIMIT = 12;
    private final ClanSearchParams _params;
    private final List<ClanSearchClan> _clans;

    public ExPledgeRecruitBoardSearch(ClanSearchParams params) {
        this._params = params;
        this._clans = ClanSearchManager.getInstance().listClans(12, params);
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._params.getCurrentPage());
        this.writeD(ClanSearchManager.getInstance().getPageCount(12));
        this.writeD(this._clans.size());
        for (ClanSearchClan clanHolder : this._clans) {
            this.writeD(clanHolder.getClanId());
            this.writeD(0);
        }
        for (ClanSearchClan clanHolder : this._clans) {
            Clan clan = ClanTable.getInstance().getClan(clanHolder.getClanId());
            this.writeD(clan.getCrestId());
            this.writeD(clan.getAlliance() == null ? 0 : clan.getAlliance().getAllyCrestId());
            this.writeS(clan.getName());
            this.writeS(clan.getLeaderName());
            this.writeD(clan.getLevel());
            this.writeD(clan.getAllSize());
            this.writeD(clanHolder.getSearchType().ordinal());
            this.writeS("");
            this.writeD(clanHolder.getApplication());
            this.writeD(clanHolder.getSubUnit());
        }
    }
}

