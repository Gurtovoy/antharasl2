/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.clansearch.ClanSearchClan;
import l2s.gameserver.model.clansearch.ClanSearchPlayer;
import l2s.gameserver.model.clansearch.base.ClanSearchListType;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.tables.ClanTable;

public class ExPledgeWaitingListApplied
extends L2GameServerPacket {
    private int _clanId = 0;
    private String _clanName = "";
    private String _leaderName = "";
    private int _clanLevel = 0;
    private int _memberCount = 0;
    private ClanSearchListType _searchType = ClanSearchListType.SLT_ANY;
    private String _desc = "";

    public ExPledgeWaitingListApplied(ClanSearchPlayer playerHolder) {
        Clan clan;
        ClanSearchClan clanHolder;
        if (playerHolder != null && (clanHolder = ClanSearchManager.getInstance().getClan(playerHolder.getPrefferedClanId())) != null && (clan = ClanTable.getInstance().getClan(clanHolder.getClanId())) != null) {
            this._clanId = clanHolder.getClanId();
            this._clanName = clan.getName();
            this._leaderName = clan.getLeaderName();
            this._clanLevel = clan.getLevel();
            this._memberCount = clan.getAllSize();
            this._searchType = clanHolder.getSearchType();
            this._desc = clanHolder.getDesc();
        }
    }

    public ExPledgeWaitingListApplied(Player player) {
        this(ClanSearchManager.getInstance().getWaiter(player.getObjectId()));
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._clanId);
        this.writeS(this._clanName);
        this.writeS(this._leaderName);
        this.writeD(this._clanLevel);
        this.writeD(this._memberCount);
        this.writeD(this._searchType.ordinal());
        this.writeS("");
        this.writeS(this._desc);
    }
}

