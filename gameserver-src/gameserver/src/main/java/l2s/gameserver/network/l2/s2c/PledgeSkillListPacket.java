/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.SkillEntry;

public class PledgeSkillListPacket
extends L2GameServerPacket {
    private List<SkillInfo> _allSkills = Collections.emptyList();
    private List<UnitSkillInfo> _unitSkills = new ArrayList<UnitSkillInfo>();

    public PledgeSkillListPacket(Clan clan) {
        Collection<SkillEntry> skills = clan.getSkills();
        this._allSkills = new ArrayList<SkillInfo>(skills.size());
        for (SkillEntry sk : skills) {
            this._allSkills.add(new SkillInfo(sk.getId(), sk.getLevel()));
        }
        for (SubUnit subUnit : clan.getAllSubUnits()) {
            for (SkillEntry sk : subUnit.getSkills()) {
                this._unitSkills.add(new UnitSkillInfo(subUnit.getType(), sk.getId(), sk.getLevel()));
            }
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._allSkills.size());
        this.writeD(this._unitSkills.size());
        for (SkillInfo skillInfo : this._allSkills) {
            this.writeD(skillInfo._id);
            this.writeD(skillInfo._level);
        }
        for (UnitSkillInfo unitSkillInfo : this._unitSkills) {
            this.writeD(unitSkillInfo._type);
            this.writeD(unitSkillInfo._id);
            this.writeD(unitSkillInfo._level);
        }
    }

    static class UnitSkillInfo
    extends SkillInfo {
        private int _type;

        public UnitSkillInfo(int type, int id, int level) {
            super(id, level);
            this._type = type;
        }
    }

    static class SkillInfo {
        public int _id;
        public int _level;

        public SkillInfo(int id, int level) {
            this._id = id;
            this._level = level;
        }
    }
}

