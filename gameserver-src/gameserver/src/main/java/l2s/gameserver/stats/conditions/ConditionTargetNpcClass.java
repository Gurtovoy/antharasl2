package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.scripts.Scripts;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetNpcClass
extends Condition {
    private final Class<?> _npcClass;

    public ConditionTargetNpcClass(String name) {
        Class<?> classType = null;
        try {
            classType = Class.forName("l2s.gameserver.model.instances." + name + "Instance");
        }
        catch (ClassNotFoundException e) {
            classType = Scripts.getInstance().getClasses().get("npc.model." + name + "Instance");
        }
        if (classType == null) {
            throw new IllegalArgumentException("Not found type class for type: " + name + ".");
        }
        this._npcClass = classType;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.target != null && env.target.getClass() == this._npcClass;
    }
}

