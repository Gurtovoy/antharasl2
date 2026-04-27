/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerMinMaxDamage
extends Condition {
    private final double _min;
    private final double _max;

    public ConditionPlayerMinMaxDamage(double min, double max) {
        this._min = min;
        this._max = max;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (this._min > 0.0 && env.value < this._min) {
            return false;
        }
        return !(this._max > 0.0) || !(env.value > this._max);
    }
}

