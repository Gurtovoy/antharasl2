/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public final class ConditionTargetHasBuff
extends Condition {
    private final AbnormalType _abnormalType;
    private final int _level;

    public ConditionTargetHasBuff(AbnormalType abnormalType, int level) {
        this._abnormalType = abnormalType;
        this._level = level;
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        if (target == null) {
            return false;
        }
        for (Abnormal effect : target.getAbnormalList()) {
            if (effect.getAbnormalType() != this._abnormalType) continue;
            if (this._level == -1) {
                return true;
            }
            if (effect.getAbnormalLvl() < this._level) continue;
            return true;
        }
        return false;
    }
}

