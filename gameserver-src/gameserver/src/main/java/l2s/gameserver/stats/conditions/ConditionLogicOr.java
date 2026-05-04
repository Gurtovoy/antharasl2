package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionLogicOr
extends Condition {
    private static final Condition[] emptyConditions = new Condition[0];
    public Condition[] _conditions = emptyConditions;

    public void add(Condition condition) {
        if (condition == null) {
            return;
        }
        int len = this._conditions.length;
        Condition[] tmp = new Condition[len + 1];
        System.arraycopy(this._conditions, 0, tmp, 0, len);
        tmp[len] = condition;
        this._conditions = tmp;
    }

    @Override
    protected boolean testImpl(Env env) {
        for (Condition c : this._conditions) {
            if (!c.test(env)) continue;
            return true;
        }
        return false;
    }
}

