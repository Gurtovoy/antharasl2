/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerPercentHp
extends Condition {
    private final double _hp;

    public ConditionPlayerPercentHp(double hp) {
        this._hp = hp / 100.0;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.character.getCurrentHpRatio() <= this._hp;
    }
}

