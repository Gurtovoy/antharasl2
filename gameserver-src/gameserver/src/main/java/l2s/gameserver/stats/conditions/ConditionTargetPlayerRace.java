package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetPlayerRace
extends Condition {
    private final Race _race;

    public ConditionTargetPlayerRace(String race) {
        this._race = Race.valueOf(race.toUpperCase());
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        return target != null && target.isPlayer() && this._race == ((Player)target).getRace();
    }
}

