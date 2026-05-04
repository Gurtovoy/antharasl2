/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerHasBuffId
extends Condition {
    private final int _id;
    private final int _level;

    public ConditionPlayerHasBuffId(int id, int level) {
        this._id = id;
        this._level = level;
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature character = env.character;
        if (character == null) {
            return false;
        }
        for (Abnormal effect : character.getAbnormalList()) {
            if (effect.getSkill().getId() != this._id) continue;
            if (this._level == -1) {
                return true;
            }
            if (effect.getSkill().getLevel() < this._level) continue;
            return true;
        }
        return false;
    }
}

