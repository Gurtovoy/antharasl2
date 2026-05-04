/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerPercentCp
extends Condition {
    private final double _cp;

    public ConditionPlayerPercentCp(int cp) {
        this._cp = (double)cp / 100.0;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.character.getCurrentCpRatio() <= this._cp;
    }
}

