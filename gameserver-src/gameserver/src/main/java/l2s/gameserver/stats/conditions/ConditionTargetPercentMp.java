/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetPercentMp
extends Condition {
    private final double _mp;

    public ConditionTargetPercentMp(int mp) {
        this._mp = (double)mp / 100.0;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.target != null && env.target.getCurrentMpRatio() <= this._mp;
    }
}

