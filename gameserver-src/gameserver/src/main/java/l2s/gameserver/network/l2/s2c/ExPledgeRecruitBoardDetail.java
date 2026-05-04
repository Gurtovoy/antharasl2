package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.clansearch.ClanSearchClan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeRecruitBoardDetail
extends L2GameServerPacket {
    private final ClanSearchClan _clan;

    public ExPledgeRecruitBoardDetail(ClanSearchClan clan) {
        this._clan = clan;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._clan.getClanId());
        this.writeD(this._clan.getSearchType().ordinal());
        this.writeS("");
        this.writeS(this._clan.getDesc());
        this.writeD(this._clan.getApplication());
        this.writeD(this._clan.getSubUnit());
    }
}

