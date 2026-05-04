package l2s.gameserver.stats.conditions;

import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerCanLearnSkill
extends Condition {
    private static final AcquireType[] ACQUITE_TYPES_TO_CHECK = new AcquireType[]{AcquireType.NORMAL, AcquireType.FISHING, AcquireType.GENERAL, AcquireType.HERO};
    private final int _id;
    private final int _level;

    public ConditionPlayerCanLearnSkill(int id, int level) {
        this._id = id;
        this._level = level;
    }

    @Override
    protected boolean testImpl(Env env) {
        Skill skill = SkillHolder.getInstance().getSkill(this._id, this._level);
        if (skill == null) {
            return false;
        }
        if (!env.character.isPlayer()) {
            return false;
        }
        Player player = env.character.getPlayer();
        int skillLvl = skill.getLevel();
        int haveSkillLvl = 0;
        SkillEntry knownSkillEntry = player.getKnownSkill(skill.getId());
        if (knownSkillEntry != null && (haveSkillLvl = knownSkillEntry.getTemplate().getLevel()) >= skillLvl) {
            return false;
        }
        if (skillLvl > haveSkillLvl + 1) {
            return false;
        }
        for (AcquireType at : ACQUITE_TYPES_TO_CHECK) {
            SkillLearn skillLearn;
            if (!SkillAcquireHolder.getInstance().isSkillPossible(player, skill, at) || (skillLearn = SkillAcquireHolder.getInstance().getSkillLearn(player, skill.getId(), skill.getLevel(), at)) == null || !SkillAcquireHolder.getInstance().checkLearnCondition(player, player.getClan(), skillLearn, player.getLevel(), at)) continue;
            return true;
        }
        return false;
    }
}

