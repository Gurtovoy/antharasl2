/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerMaxLevel
extends Condition {
    private final int _level;

    public ConditionPlayerMaxLevel(int level) {
        this._level = level;
    }

    @Override
    protected boolean testImpl(Env env) {
        return this._level != -1 && env.character.getLevel() <= this._level;
    }
}

