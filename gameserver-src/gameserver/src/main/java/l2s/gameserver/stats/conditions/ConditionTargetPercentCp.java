/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetPercentCp
extends Condition {
    private final double _cp;

    public ConditionTargetPercentCp(int cp) {
        this._cp = (double)cp / 100.0;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.target != null && env.target.getCurrentCpRatio() <= this._cp;
    }
}

