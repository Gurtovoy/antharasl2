package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerFlagged
extends Condition {
    private final boolean _flagged;

    public ConditionPlayerFlagged(boolean flagged) {
        this._flagged = flagged;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (this._flagged) {
            return ((Player)env.character).getPvpFlag() > 0;
        }
        return ((Player)env.character).getPvpFlag() <= 0;
    }
}

