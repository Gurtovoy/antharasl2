package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerMinLevel
extends Condition {
    private final int _level;

    public ConditionPlayerMinLevel(int level) {
        this._level = level;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.character.getLevel() >= this._level;
    }
}

