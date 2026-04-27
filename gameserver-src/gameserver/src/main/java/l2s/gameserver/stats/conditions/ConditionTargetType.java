/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetType
extends Condition {
    private final TargetType _targetType;

    public ConditionTargetType(String targetType) {
        this._targetType = TargetType.valueOf(targetType.toUpperCase());
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.target;
        switch (this._targetType) {
            case PLAYABLE: {
                return target != null && target.isPlayable();
            }
            case PLAYER: {
                return target != null && target.isPlayer();
            }
            case NPC: {
                return target != null && target.isNpc();
            }
            case MONSTER: {
                return target != null && target.isMonster();
            }
            case RAID_BOSS: {
                return target != null && target.isRaid();
            }
            case SERVITOR: {
                return target != null && target.isServitor();
            }
            case SUMMON: {
                return target != null && target.isSummon();
            }
            case PET: {
                return target != null && target.isPet();
            }
        }
        return true;
    }

    private static enum TargetType {
        NPC,
        MONSTER,
        RAID_BOSS,
        PLAYABLE,
        PLAYER,
        SERVITOR,
        SUMMON,
        PET;

    }
}

