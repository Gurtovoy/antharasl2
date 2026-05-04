package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionLogicNot
extends Condition {
    private final Condition _condition;

    public ConditionLogicNot(Condition condition) {
        this._condition = condition;
    }

    @Override
    protected boolean testImpl(Env env) {
        return !this._condition.test(env);
    }
}

