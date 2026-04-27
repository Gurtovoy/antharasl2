/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeRecruitInfo
extends L2GameServerPacket {
    private final String _clanName;
    private final String _leaderName;
    private final int _clanLevel;
    private final int _clanMemberCount;
    private final List<SubUnit> _subUnits = new ArrayList<SubUnit>();

    public ExPledgeRecruitInfo(Clan clan) {
        this._clanName = clan.getName();
        this._leaderName = clan.getLeader().getName();
        this._clanLevel = clan.getLevel();
        this._clanMemberCount = clan.getAllSize();
        for (SubUnit su : clan.getAllSubUnits()) {
            if (su.getType() == 0) continue;
            this._subUnits.add(su);
        }
    }

    @Override
    protected void writeImpl() {
        this.writeS(this._clanName);
        this.writeS(this._leaderName);
        this.writeD(this._clanLevel);
        this.writeD(this._clanMemberCount);
        this.writeD(this._subUnits.size());
        for (SubUnit su : this._subUnits) {
            this.writeD(su.getType());
            this.writeS(su.getName());
        }
    }
}

