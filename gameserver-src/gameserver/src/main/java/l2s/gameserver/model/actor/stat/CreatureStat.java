/*
 * This file was originally decompiled from L2S rev.[31495].
 * Refactored: removed CFR decompiler artifacts.
 */
package l2s.gameserver.model.actor.stat;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.stats.Calculator;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;

public class CreatureStat
{
    protected final Creature _owner;
    protected final Calculator[] _calculators = new Calculator[Stats.NUM_STATS];

    public CreatureStat(Creature owner)
    {
        this._owner = owner;
    }

    public Creature getOwner()
    {
        return _owner;
    }

    public Calculator[] getCalculators()
    {
        return _calculators;
    }

    public void addFuncs(Func... funcs)
    {
        synchronized (_calculators)
        {
            for (Func func : funcs)
            {
                int stat = func.stat.ordinal();
                if (_calculators[stat] == null)
                {
                    _calculators[stat] = new Calculator(func.stat, _owner);
                }
                _calculators[stat].addFunc(func);
            }
        }
    }

    public void removeFuncs(Func... funcs)
    {
        synchronized (_calculators)
        {
            for (Func func : funcs)
            {
                int stat = func.stat.ordinal();
                if (_calculators[stat] == null)
                {
                    continue;
                }
                _calculators[stat].removeFunc(func);
            }
        }
    }

    public void removeFuncsByOwner(Object owner)
    {
        synchronized (_calculators)
        {
            for (Calculator calculator : _calculators)
            {
                if (calculator == null)
                {
                    continue;
                }
                calculator.removeOwner(owner);
            }
        }
    }

    public double getAdd(Stats stat, Creature target, Skill skill)
    {
        return calc(stat, 0.0, target, skill, StatModifierType.DIFF);
    }

    public double getAdd(Stats stat)
    {
        return getAdd(stat, null, null);
    }

    public double getMul(Stats stat, Creature target, Skill skill)
    {
        return (100.0 + calc(stat, 0.0, target, skill, StatModifierType.PER)) / 100.0;
    }

    public double getMul(Stats stat)
    {
        return getMul(stat, null, null);
    }

    public double calc(Stats stat)
    {
        return calc(stat, stat.getInit(), null, null, null);
    }

    public double calc(Stats stat, Creature target, Skill skill)
    {
        return calc(stat, stat.getInit(), target, skill, null);
    }

    public double calc(Stats stat, double init)
    {
        return calc(stat, init, null, null, null);
    }

    public double calc(Stats stat, double init, Creature target, Skill skill)
    {
        return calc(stat, init, target, skill, null);
    }

    public double calc(Stats stat, double init, Creature target, Skill skill, StatModifierType modifierType)
    {
        Calculator c = _calculators[stat.ordinal()];
        if (c == null)
        {
            return init;
        }
        Env env = new Env(_owner, target, skill);
        env.value = init;
        c.calc(env, modifierType);
        return env.value;
    }
}
