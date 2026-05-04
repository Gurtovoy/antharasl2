/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public final class ConditionHasSkill
extends Condition {
    private final Integer _id;
    private final int _level;

    public ConditionHasSkill(Integer id, int level) {
        this._id = id;
        this._level = level;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.character.getSkillLevel(this._id) >= this._level;
    }
}

