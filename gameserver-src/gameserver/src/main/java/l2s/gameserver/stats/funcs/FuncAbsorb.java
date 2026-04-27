/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.stats.funcs;

import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.templates.StatsSet;

public class FuncAbsorb
extends Func {
    private final double chance;

    public FuncAbsorb(Stats stat, int order, Object owner, double value, StatsSet params) {
        super(stat, order, owner, value, params);
        this.chance = params.getDouble("chance", 100.0);
    }

    @Override
    public void calc(Env env, StatModifierType modifierType) {
        double chance = this.chance * Config.ALT_VAMPIRIC_CHANCE_MOD;
        if (chance >= 100.0 || Rnd.chance((double)chance)) {
            env.value += this.value;
        }
    }
}

