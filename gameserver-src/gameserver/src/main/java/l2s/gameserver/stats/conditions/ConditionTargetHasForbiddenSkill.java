/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public final class ConditionTargetHasForbiddenSkill
extends Condition {
    private final int _skillId;

    public ConditionTargetHasForbiddenSkill(int skillId) {
        this._skillId = skillId;
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        if (!target.isPlayable()) {
            return false;
        }
        return target.getSkillLevel(this._skillId) <= 0;
    }
}

