/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.funcs;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.templates.StatsSet;

public class FuncNew
extends Func {
    private final StatModifierType _modifierType;
    private final Stats _dependStat;

    public FuncNew(Stats stat, int order, Object owner, double value, StatsSet params) {
        super(stat, order, owner, value, params);
        this._modifierType = (StatModifierType)((Object)params.getObject("mode"));
        String dependStatName = params.getString("depend_stat", null);
        this._dependStat = dependStatName != null ? Stats.valueOfXml(dependStatName) : null;
    }

    @Override
    public void calc(Env env, StatModifierType modifierType) {
        if (this._dependStat != null) {
            if (modifierType == null || modifierType == StatModifierType.DIFF) {
                switch (this._dependStat) {
                    case POWER_DEFENCE: {
                        env.value += (double)env.character.getPDef(env.target) * 0.01 * this.value;
                        break;
                    }
                    case MAGIC_DEFENCE: {
                        env.value += (double)env.character.getMDef(env.target, env.skill) * 0.01 * this.value;
                        break;
                    }
                    case POWER_ATTACK: {
                        env.value += (double)env.character.getPAtk(env.target) * 0.01 * this.value;
                        break;
                    }
                    case MAGIC_ATTACK: {
                        env.value += (double)env.character.getMAtk(env.target, env.skill) * 0.01 * this.value;
                        break;
                    }
                    case BASE_P_CRITICAL_RATE: {
                        env.value += (double)env.character.getPCriticalHit(env.target) * 0.01 * this.value;
                        break;
                    }
                    case BASE_M_CRITICAL_RATE: {
                        env.value += (double)env.character.getMCriticalHit(env.target, env.skill) * 0.01 * this.value;
                    }
                }
            }
        } else if (this._modifierType == modifierType) {
            switch (this._modifierType) {
                case DIFF: 
                case PER: {
                    env.value += this.value;
                }
            }
        } else if (modifierType == null) {
            switch (this._modifierType) {
                case DIFF: {
                    env.value += this.value;
                    break;
                }
                case PER: {
                    env.value *= (100.0 + this.value) / 100.0;
                }
            }
        }
    }
}

