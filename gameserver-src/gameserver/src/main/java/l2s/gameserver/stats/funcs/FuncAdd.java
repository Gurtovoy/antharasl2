/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.funcs;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.templates.StatsSet;

public class FuncAdd
extends Func {
    public FuncAdd(Stats stat, int order, Object owner, double value, StatsSet params) {
        super(stat, order, owner, value, params);
    }

    @Override
    public void calc(Env env, StatModifierType modifierType) {
        env.value += this.value;
    }
}

