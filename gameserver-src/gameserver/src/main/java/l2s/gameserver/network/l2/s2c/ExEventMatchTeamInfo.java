/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExEventMatchTeamInfo
extends L2GameServerPacket {
    private int leader_id;
    private int loot;
    private List<EventMatchTeamInfo> members = new ArrayList<EventMatchTeamInfo>();

    public ExEventMatchTeamInfo(List<Player> party, Player exclude) {
        this.leader_id = party.get(0).getObjectId();
        this.loot = party.get(0).getParty().getLootDistribution();
        for (Player member : party) {
            if (member.equals(exclude)) continue;
            this.members.add(new EventMatchTeamInfo(member));
        }
    }

    @Override
    protected void writeImpl() {
    }

    public static class MathMember {
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
    }

    public static class EventMatchTeamInfo {
        public MathMember member = new MathMember();
        public List<MathMember> m_servitors;

        public EventMatchTeamInfo(Player player) {
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
            this.m_servitors = new ArrayList<MathMember>();
            for (Servitor s : player.getServitors()) {
                MathMember m_servitor = new MathMember();
                m_servitor.name = s.getName();
                m_servitor.objId = s.getObjectId();
                m_servitor.npcId = s.getNpcId() + 1000000;
                m_servitor.curHp = (int)s.getCurrentHp();
                m_servitor.maxHp = s.getMaxHp();
                m_servitor.curMp = (int)s.getCurrentMp();
                m_servitor.maxMp = s.getMaxMp();
                m_servitor.level = s.getLevel();
                this.m_servitors.add(m_servitor);
            }
        }
    }
}

