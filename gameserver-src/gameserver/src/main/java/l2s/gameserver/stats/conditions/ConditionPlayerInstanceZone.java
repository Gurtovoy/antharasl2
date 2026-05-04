package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerInstanceZone
extends Condition {
    private final int _id;

    public ConditionPlayerInstanceZone(int id) {
        this._id = id;
    }

    @Override
    protected boolean testImpl(Env env) {
        Reflection ref = env.character.getReflection();
        return ref.getInstancedZoneId() == this._id;
    }
}

