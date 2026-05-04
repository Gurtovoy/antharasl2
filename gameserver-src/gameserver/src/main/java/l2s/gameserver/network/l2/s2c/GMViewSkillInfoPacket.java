package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.SkillEntry;

public class GMViewSkillInfoPacket
extends L2GameServerPacket {
    private final String _charName;
    private final Collection<SkillEntry> _skills;
    private final Player _targetChar;

    public GMViewSkillInfoPacket(Player cha) {
        this._charName = cha.getName();
        this._skills = cha.getAllSkills();
        this._targetChar = cha;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._charName);
        this.writeD(this._skills.size());
        for (SkillEntry skillEntry : this._skills) {
            Skill temp = skillEntry.getTemplate();
            this.writeD(temp.isActive() || temp.isToggle() ? 0 : 1);
            this.writeD(temp.getDisplayLevel());
            this.writeD(temp.getDisplayId());
            this.writeD(temp.getReuseSkillId());
            this.writeC(this._targetChar.isUnActiveSkill(temp.getId()) ? 1 : 0);
            this.writeC(0);
        }
        this.writeD(0);
    }
}

