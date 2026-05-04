/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PartySmallWindowAllPacket
extends L2GameServerPacket {
    private int leaderId;
    private int loot;
    private List<PartySmallWindowMemberInfo> members = new ArrayList<PartySmallWindowMemberInfo>();

    public PartySmallWindowAllPacket(Party party, Player leader, Player exclude) {
        this.leaderId = leader.getObjectId();
        this.loot = party.getLootDistribution();
        for (Player member : party.getPartyMembers()) {
            if (member == exclude) continue;
            this.members.add(new PartySmallWindowMemberInfo(member));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.leaderId);
        this.writeC(this.loot);
        this.writeC(this.members.size());
        for (PartySmallWindowMemberInfo mi : this.members) {
            this.writeD(mi.member.objId);
            this.writeS(mi.member.name);
            this.writeD(mi.member.curCp);
            this.writeD(mi.member.maxCp);
            this.writeD(mi.member.curHp);
            this.writeD(mi.member.maxHp);
            this.writeD(mi.member.curMp);
            this.writeD(mi.member.maxMp);
            this.writeD(0);
            this.writeC(mi.member.level);
            this.writeH(mi.member.classId);
            this.writeC(mi.member.sex);
            this.writeH(mi.member.raceId);
            this.writeD(mi.m_servitors.size());
            for (PartyMember servitor : mi.m_servitors) {
                this.writeD(servitor.objId);
                this.writeD(servitor.npcId);
                this.writeC(servitor.type);
                this.writeS(servitor.name);
                this.writeD(servitor.curHp);
                this.writeD(servitor.maxHp);
                this.writeD(servitor.curMp);
                this.writeD(servitor.maxMp);
                this.writeC(servitor.level);
            }
        }
    }

    public static class PartyMember {
        public String name;
        public int objId;
        public int npcId;
        public int curCp;
        public int maxCp;
        public int curHp;
        public int maxHp;
        public int curMp;
        public int maxMp;
        public int level;
        public int classId;
        public int raceId;
        public int type;
        public int sex;
        public int isPartySubstituteStarted;
    }

    public static class PartySmallWindowMemberInfo {
        public PartyMember member = new PartyMember();
        public List<PartyMember> m_servitors;

        public PartySmallWindowMemberInfo(Player player) {
            this.member.name = player.getName();
            this.member.objId = player.getObjectId();
            this.member.curCp = (int)player.getCurrentCp();
            this.member.maxCp = player.getMaxCp();
            this.member.curHp = (int)player.getCurrentHp();
            this.member.maxHp = player.getMaxHp();
            this.member.curMp = (int)player.getCurrentMp();
            this.member.maxMp = player.getMaxMp();
            this.member.level = player.getLevel();
            this.member.classId = player.getClassId().getId();
            this.member.raceId = player.getRace().ordinal();
            this.member.sex = player.getSex().ordinal();
            this.member.isPartySubstituteStarted = player.isPartySubstituteStarted() ? 1 : 0;
            this.m_servitors = new ArrayList<PartyMember>();
            for (Servitor s : player.getServitors()) {
                PartyMember m_servitor = new PartyMember();
                m_servitor.name = s.getName();
                m_servitor.objId = s.getObjectId();
                m_servitor.npcId = s.getNpcId() + 1000000;
                m_servitor.curHp = (int)s.getCurrentHp();
                m_servitor.maxHp = s.getMaxHp();
                m_servitor.curMp = (int)s.getCurrentMp();
                m_servitor.maxMp = s.getMaxMp();
                m_servitor.level = s.getLevel();
                m_servitor.type = s.getServitorType();
                this.m_servitors.add(m_servitor);
            }
        }
    }
}

