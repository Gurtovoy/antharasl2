package l2s.gameserver.model.actor.stat;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.stats.Calculator;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;

public class CreatureStat {
    protected final Creature _owner;
    protected final Calculator[] _calculators = new Calculator[Stats.NUM_STATS];

    public CreatureStat(Creature owner) {
        this._owner = owner;
    }

    public Creature getOwner() {
        return this._owner;
    }

    public Calculator[] getCalculators() {
        return this._calculators;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void addFuncs(Func ... funcs) {
        Calculator[] calculatorArray = this._calculators;
        synchronized (this._calculators) {
            for (Func func : funcs) {
                int stat = func.stat.ordinal();
                if (this._calculators[stat] == null) {
                    this._calculators[stat] = new Calculator(func.stat, this._owner);
                }
                this._calculators[stat].addFunc(func);
            }
            // ** MonitorExit[var2_2] (shouldn't be in output)
            return;
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removeFuncs(Func ... funcs) {
        Calculator[] calculatorArray = this._calculators;
        synchronized (this._calculators) {
            for (Func func : funcs) {
                int stat = func.stat.ordinal();
                if (this._calculators[stat] == null) continue;
                this._calculators[stat].removeFunc(func);
            }
            // ** MonitorExit[var2_2] (shouldn't be in output)
            return;
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removeFuncsByOwner(Object owner) {
        Calculator[] calculatorArray = this._calculators;
        synchronized (this._calculators) {
            for (Calculator calculator : this._calculators) {
                if (calculator == null) continue;
                calculator.removeOwner(owner);
            }
            // ** MonitorExit[var2_2] (shouldn't be in output)
            return;
        }
    }

    public double getAdd(Stats stat, Creature target, Skill skill) {
        return this.calc(stat, 0.0, target, skill, StatModifierType.DIFF);
    }

    public double getAdd(Stats stat) {
        return this.getAdd(stat, null, null);
    }

    public double getMul(Stats stat, Creature target, Skill skill) {
        return (100.0 + this.calc(stat, 0.0, target, skill, StatModifierType.PER)) / 100.0;
    }

    public double getMul(Stats stat) {
        return this.getMul(stat, null, null);
    }

    public double calc(Stats stat) {
        return this.calc(stat, stat.getInit(), null, null, null);
    }

    public double calc(Stats stat, Creature target, Skill skill) {
        return this.calc(stat, stat.getInit(), target, skill, null);
    }

    public double calc(Stats stat, double init) {
        return this.calc(stat, init, null, null, null);
    }

    public double calc(Stats stat, double init, Creature target, Skill skill) {
        return this.calc(stat, init, target, skill, null);
    }

    public double calc(Stats stat, double init, Creature target, Skill skill, StatModifierType modifierType) {
        Calculator c = this._calculators[stat.ordinal()];
        if (c == null) {
            return init;
        }
        Env env = new Env(this._owner, target, skill);
        env.value = init;
        c.calc(env, modifierType);
        return env.value;
    }
}

