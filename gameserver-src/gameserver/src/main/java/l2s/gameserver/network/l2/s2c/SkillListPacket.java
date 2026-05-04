package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.SkillEntry;

public class SkillListPacket
extends L2GameServerPacket {
    private final Collection<SkillEntry> _skills;
    private final Player _player;
    private final int _learnedSkillId;

    public SkillListPacket(Player player) {
        this._skills = player.getAllSkills();
        this._player = player;
        this._learnedSkillId = 0;
    }

    public SkillListPacket(Player player, int learnedSkillId) {
        this._skills = player.getAllSkills();
        this._player = player;
        this._learnedSkillId = learnedSkillId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._skills.size());
        for (SkillEntry skillEntry : this._skills) {
            Skill temp = skillEntry.getTemplate();
            this.writeD(temp.isActive() || temp.isToggle() ? 0 : 1);
            this.writeD(temp.getDisplayLevel());
            this.writeD(temp.getDisplayId());
            this.writeD(temp.getReuseSkillId());
            this.writeC(this._player.isUnActiveSkill(temp.getId()) ? 1 : 0);
            this.writeC(0);
        }
        this.writeD(this._learnedSkillId);
    }
}

