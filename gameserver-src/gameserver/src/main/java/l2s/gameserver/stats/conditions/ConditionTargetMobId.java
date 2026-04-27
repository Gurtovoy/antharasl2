/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetMobId
extends Condition {
    private final int _mobId;

    public ConditionTargetMobId(int mobId) {
        this._mobId = mobId;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.target != null && env.target.getNpcId() == this._mobId;
    }
}

