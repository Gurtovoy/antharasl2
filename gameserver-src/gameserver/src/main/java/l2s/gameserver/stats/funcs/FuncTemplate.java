/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.funcs;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.templates.StatsSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class FuncTemplate {
    private static final Logger _log = LoggerFactory.getLogger(FuncTemplate.class);
    public static final FuncTemplate[] EMPTY_ARRAY = new FuncTemplate[0];
    public final Condition _applyCond;
    public final Stats _stat;
    public final int _order;
    public final double _value;
    public final StatsSet _params;
    public Class<?> _func;
    public Constructor<?> _constructor;

    private FuncTemplate(StatsSet params) {
        this._applyCond = (Condition)params.getObject("condition", null);
        this._stat = (Stats)((Object)params.getObject("stat"));
        StatModifierType modifierType = (StatModifierType)((Object)params.getObject("mode", null));
        this._order = params.getInteger("order", modifierType == StatModifierType.PER ? 48 : 64);
        this._value = params.getDouble("value", 0.0);
        this._params = params;
        try {
            this._func = Class.forName("l2s.gameserver.stats.funcs.Func" + params.getString("function"));
            this._constructor = this._func.getConstructor(Stats.class, Integer.TYPE, Object.class, Double.TYPE, StatsSet.class);
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
    }

    public Func getFunc(Object owner) {
        try {
            Func f = (Func)this._constructor.newInstance(new Object[]{this._stat, this._order, owner, this._value, this._params});
            if (this._applyCond != null) {
                f.setCondition(this._applyCond);
            }
            return f;
        }
        catch (IllegalAccessException e) {
            _log.error("", (Throwable)e);
            return null;
        }
        catch (InstantiationException e) {
            _log.error("", (Throwable)e);
            return null;
        }
        catch (InvocationTargetException e) {
            _log.error("", (Throwable)e);
            return null;
        }
    }

    public static FuncTemplate makeTemplate(Condition applyCond, String func, Stats stat, int order, double value) {
        StatsSet params = new StatsSet();
        params.set("stat", stat);
        params.set("function", func);
        params.set("condition", applyCond);
        params.set("order", order);
        params.set("value", value);
        return new FuncTemplate(params);
    }

    public static FuncTemplate makeTemplate(StatsSet params) {
        return new FuncTemplate(params);
    }
}

