package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeShowInfoUpdatePacket
extends L2GameServerPacket {
    private int clan_id;
    private int clan_level;
    private int clan_rank;
    private int clan_rep;
    private int crest_id;
    private int ally_id;
    private int ally_crest;
    private final boolean atwar;
    private String ally_name = "";
    private int _hasCastle;
    private int _hasClanHall;
    private int _hasInstantClanHall;
    private boolean _isDisbanded;

    public PledgeShowInfoUpdatePacket(Clan clan) {
        this.clan_id = clan.getClanId();
        this.clan_level = clan.getLevel();
        this._hasCastle = clan.getCastle();
        ClanHall clanHall = ResidenceHolder.getInstance().getResidence(ClanHall.class, clan.getHasHideout());
        if (clanHall != null) {
            this._hasClanHall = clanHall.getId();
            this._hasInstantClanHall = clanHall.getInstantZoneId();
        } else {
            this._hasClanHall = 0;
            this._hasInstantClanHall = 0;
        }
        this.clan_rank = clan.getRank();
        this.clan_rep = clan.getReputationScore();
        this.crest_id = clan.getCrestId();
        this.ally_id = clan.getAllyId();
        this.atwar = clan.isAtWar();
        this._isDisbanded = clan.isPlacedForDisband();
        Alliance ally = clan.getAlliance();
        if (ally != null) {
            this.ally_name = ally.getAllyName();
            this.ally_crest = ally.getAllyCrestId();
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.clan_id);
        this.writeD(Config.REQUEST_ID);
        this.writeD(this.crest_id);
        this.writeD(this.clan_level);
        this.writeD(this._hasCastle);
        if (this._hasInstantClanHall > 0) {
            this.writeD(1);
            this.writeD(this._hasInstantClanHall);
        } else if (this._hasClanHall != 0) {
            this.writeD(0);
            this.writeD(this._hasClanHall);
        } else {
            this.writeD(0);
            this.writeD(0);
        }
        this.writeD(0);
        this.writeD(this.clan_rank);
        this.writeD(this.clan_rep);
        this.writeD(this._isDisbanded ? 3 : 0);
        this.writeD(0);
        this.writeD(this.ally_id);
        this.writeS(this.ally_name);
        this.writeD(this.ally_crest);
        this.writeD(this.atwar);
        this.writeD(0);
        this.writeD(0);
    }
}

