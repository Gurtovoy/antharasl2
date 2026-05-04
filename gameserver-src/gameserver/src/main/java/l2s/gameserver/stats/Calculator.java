package l2s.gameserver.stats;

import java.util.Arrays;
import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.model.Creature;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.stats.funcs.FuncOwner;

public final class Calculator {
    private Func[] _functions;
    private double _base;
    private double _last;
    public final Stats _stat;
    public final Creature _character;

    public Calculator(Stats stat, Creature character) {
        this._stat = stat;
        this._character = character;
        this._functions = Func.EMPTY_FUNC_ARRAY;
    }

    public int size() {
        return this._functions.length;
    }

    public void addFunc(Func f) {
        this._functions = (Func[])ArrayUtils.add((Object[])this._functions, (Object)f);
        Arrays.sort(this._functions);
    }

    public void removeFunc(Func f) {
        this._functions = (Func[])ArrayUtils.remove((Object[])this._functions, (Object)f);
        if (this._functions.length == 0) {
            this._functions = Func.EMPTY_FUNC_ARRAY;
        } else {
            Arrays.sort(this._functions);
        }
    }

    public void removeOwner(Object owner) {
        Func[] tmp;
        for (Func element : tmp = this._functions) {
            if (element.owner != owner) continue;
            this.removeFunc(element);
        }
    }

    public void calc(Env env, StatModifierType modifierType) {
        Func[] funcs = this._functions;
        this._base = env.value;
        boolean overrideLimits = false;
        for (Func func : funcs) {
            if (func == null) continue;
            if (func.owner instanceof FuncOwner) {
                if (!((FuncOwner)func.owner).isFuncEnabled()) continue;
                if (((FuncOwner)func.owner).overrideLimits()) {
                    overrideLimits = true;
                }
            }
            if (func.getCondition() != null && !func.getCondition().test(env)) continue;
            func.calc(env, modifierType);
        }
        if (!overrideLimits) {
            env.value = this._stat.validate(env.value);
        }
        if (env.value != this._last) {
            double last = this._last;
            this._last = env.value;
        }
    }

    public Func[] getFunctions() {
        return this._functions;
    }

    public double getBase() {
        return this._base;
    }

    public double getLast() {
        return this._last;
    }
}

