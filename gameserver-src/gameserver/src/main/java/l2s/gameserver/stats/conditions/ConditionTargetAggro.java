/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetAggro
extends Condition {
    private final boolean _isAggro;

    public ConditionTargetAggro(boolean isAggro) {
        this._isAggro = isAggro;
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        if (target == null) {
            return false;
        }
        if (target.isMonster()) {
            return ((MonsterInstance)target).isAggressive() == this._isAggro;
        }
        if (target.isPlayer()) {
            return target.isPK();
        }
        return false;
    }
}

