package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.pledge.RankPrivs;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeReceivePowerInfo
extends L2GameServerPacket {
    private int PowerGrade;
    private int privs;
    private String member_name;

    public PledgeReceivePowerInfo(UnitMember member) {
        RankPrivs temp;
        this.PowerGrade = member.getPowerGrade();
        this.member_name = member.getName();
        this.privs = member.isClanLeader() ? 0xFFFFFE : ((temp = member.getClan().getRankPrivs(member.getPowerGrade())) != null ? temp.getPrivs() : 0);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.PowerGrade);
        this.writeS(this.member_name);
        this.writeD(this.privs);
    }
}

