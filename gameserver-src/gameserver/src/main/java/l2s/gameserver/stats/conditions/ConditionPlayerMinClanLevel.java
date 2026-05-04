package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerMinClanLevel
extends Condition {
    private final int _value;

    public ConditionPlayerMinClanLevel(int value) {
        this._value = value;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return this._value <= 0;
        }
        Clan clan = env.character.getPlayer().getClan();
        if (clan == null) {
            return this._value <= 0;
        }
        return this._value <= clan.getLevel();
    }
}

