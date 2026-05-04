/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetMinDistance
extends Condition {
    private final int _distance;

    public ConditionTargetMinDistance(int distance) {
        this._distance = distance;
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        if (target == null) {
            return false;
        }
        return !env.character.isInRange(target.getLoc(), this._distance);
    }
}

