package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.base.PledgeRank;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerMinPledgeRank
extends Condition {
    private final PledgeRank _rank;

    public ConditionPlayerMinPledgeRank(PledgeRank rank) {
        this._rank = rank;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        return env.character.getPlayer().getPledgeRank().ordinal() >= this._rank.ordinal();
    }
}

