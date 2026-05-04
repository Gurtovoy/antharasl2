package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionUsingSkill
extends Condition {
    private int _id;

    public ConditionUsingSkill(int id) {
        this._id = id;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (env.skill == null) {
            return false;
        }
        return env.skill.getId() == this._id;
    }
}

