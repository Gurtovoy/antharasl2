/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerCastingSkillId
extends Condition {
    private final int _skillId;

    public ConditionPlayerCastingSkillId(int skillId) {
        this._skillId = skillId;
    }

    @Override
    protected boolean testImpl(Env env) {
        SkillEntry skillEntry = env.character.getSkillCast(SkillCastingType.NORMAL).getSkillEntry();
        if (skillEntry != null && skillEntry.getId() == this._skillId) {
            return true;
        }
        skillEntry = env.character.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry();
        return skillEntry != null && skillEntry.getId() == this._skillId;
    }
}

