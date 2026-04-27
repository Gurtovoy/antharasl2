/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public final class ConditionTargetHasBuffId
extends Condition {
    private final int _id;
    private final int _level;

    public ConditionTargetHasBuffId(int id, int level) {
        this._id = id;
        this._level = level;
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        if (target == null) {
            return false;
        }
        for (Abnormal effect : target.getAbnormalList()) {
            if (effect.getSkill().getId() != this._id) continue;
            if (this._level == -1) {
                return true;
            }
            if (effect.getSkill().getLevel() < this._level) continue;
            return true;
        }
        return false;
    }

    @Override
    public void init() {
        if (this._level == -1) {
            for (Skill skill : SkillHolder.getInstance().getSkills(this._id)) {
                skill.setShowPlayerAbnormal(true);
                skill.setShowNpcAbnormal(true);
            }
        } else {
            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, this._id, this._level);
            if (skillEntry != null) {
                skillEntry.getTemplate().setShowPlayerAbnormal(true);
                skillEntry.getTemplate().setShowNpcAbnormal(true);
            }
        }
    }
}

