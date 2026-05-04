package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerAgathion
extends Condition {
    private final int _agathionId;

    public ConditionPlayerAgathion(int agathionId) {
        this._agathionId = agathionId;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        if (((Player)env.character).getAgathionId() > 0 && this._agathionId == -1) {
            return true;
        }
        return ((Player)env.character).getAgathionId() == this._agathionId;
    }
}

