package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerPercentMp
extends Condition {
    private final double _mp;

    public ConditionPlayerPercentMp(int mp) {
        this._mp = (double)mp / 100.0;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.character.getCurrentMpRatio() <= this._mp;
    }
}

