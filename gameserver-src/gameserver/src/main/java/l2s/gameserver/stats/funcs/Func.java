/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.funcs;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.StatsSet;

public abstract class Func
implements Comparable<Func> {
    public static final Func[] EMPTY_FUNC_ARRAY = new Func[0];
    public final Stats stat;
    public final int order;
    public final Object owner;
    public final double value;
    public final StatsSet params;
    protected Condition cond;

    public Func(Stats stat, int order, Object owner) {
        this(stat, order, owner, 0.0, StatsSet.EMPTY);
    }

    public Func(Stats stat, int order, Object owner, double value, StatsSet params) {
        this.stat = stat;
        this.order = order;
        this.owner = owner;
        this.value = value;
        this.params = params;
    }

    public void setCondition(Condition cond) {
        this.cond = cond;
    }

    public Condition getCondition() {
        return this.cond;
    }

    public abstract void calc(Env var1, StatModifierType var2);

    @Override
    public int compareTo(Func f) throws NullPointerException {
        return this.order - f.order;
    }
}

