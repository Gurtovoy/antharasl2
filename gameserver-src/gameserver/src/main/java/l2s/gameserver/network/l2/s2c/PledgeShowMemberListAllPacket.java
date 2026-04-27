/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeShowMemberListAllPacket
extends L2GameServerPacket {
    private int _clanObjectId;
    private int _clanCrestId;
    private int _level;
    private int _rank;
    private int _reputation;
    private int _allianceObjectId;
    private int _allianceCrestId;
    private int _hasCastle;
    private int _hasClanHall;
    private int _hasInstantClanHall;
    private boolean _isDisbanded;
    private boolean _atClanWar;
    private String _unitName;
    private String _leaderName;
    private String _allianceName;
    private int _pledgeType;
    private List<PledgePacketMember> _members;

    public PledgeShowMemberListAllPacket(Clan clan, SubUnit sub) {
        this._pledgeType = sub.getType();
        this._clanObjectId = clan.getClanId();
        this._unitName = sub.getName();
        this._leaderName = sub.getLeaderName();
        this._clanCrestId = clan.getCrestId();
        this._level = clan.getLevel();
        this._hasCastle = clan.getCastle();
        ClanHall clanHall = ResidenceHolder.getInstance().getResidence(ClanHall.class, clan.getHasHideout());
        if (clanHall != null) {
            this._hasClanHall = clanHall.getId();
            this._hasInstantClanHall = clanHall.getInstantZoneId();
        } else {
            this._hasClanHall = 0;
            this._hasInstantClanHall = 0;
        }
        this._rank = clan.getRank();
        this._reputation = clan.getReputationScore();
        this._atClanWar = clan.isAtWar();
        this._isDisbanded = clan.isPlacedForDisband();
        Alliance ally = clan.getAlliance();
        if (ally != null) {
            this._allianceObjectId = ally.getAllyId();
            this._allianceName = ally.getAllyName();
            this._allianceCrestId = ally.getAllyCrestId();
        }
        this._members = new ArrayList<PledgePacketMember>(sub.size());
        for (UnitMember m : sub.getUnitMembers()) {
            this._members.add(new PledgePacketMember(m));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._pledgeType == 0 ? 0 : 1);
        this.writeD(this._clanObjectId);
        this.writeD(Config.REQUEST_ID);
        this.writeD(this._pledgeType);
        this.writeS(this._unitName);
        this.writeS(this._leaderName);
        this.writeD(this._clanCrestId);
        this.writeD(this._level);
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
        this.writeD(this._rank);
        this.writeD(this._reputation);
        this.writeD(this._isDisbanded ? 3 : 0);
        this.writeD(0);
        this.writeD(this._allianceObjectId);
        this.writeS(this._allianceName);
        this.writeD(this._allianceCrestId);
        this.writeD(this._atClanWar);
        this.writeD(0);
        this.writeD(this._members.size());
        for (PledgePacketMember m : this._members) {
            this.writeS(m._name);
            this.writeD(m._level);
            this.writeD(m._classId);
            this.writeD(m._sex);
            this.writeD(m._race);
            this.writeD(m._online);
            this.writeD(m._hasSponsor ? 1 : 0);
            this.writeC(m._attendance);
        }
    }

    private class PledgePacketMember {
        private String _name;
        private int _level;
        private int _classId;
        private int _sex;
        private int _race;
        private int _online;
        private boolean _hasSponsor;
        private int _attendance;

        public PledgePacketMember(UnitMember m) {
            this._name = m.getName();
            this._level = m.getLevel();
            this._classId = m.getClassId();
            this._sex = m.getSex();
            this._race = 0;
            this._online = m.isOnline() ? m.getObjectId() : 0;
            this._hasSponsor = m.getSponsor() != 0;
            this._attendance = m.getAttendanceType().ordinal();
        }
    }
}

