package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetPercentHp
extends Condition {
    private final double _hp;

    public ConditionTargetPercentHp(double hp) {
        this._hp = hp / 100.0;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.target != null && env.target.getCurrentHpRatio() <= this._hp;
    }
}

