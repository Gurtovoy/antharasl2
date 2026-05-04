package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public abstract class ConditionInventory
extends Condition {
    protected final int _slot;

    public ConditionInventory(int slot) {
        this._slot = slot;
    }

    @Override
    protected abstract boolean testImpl(Env var1);
}

