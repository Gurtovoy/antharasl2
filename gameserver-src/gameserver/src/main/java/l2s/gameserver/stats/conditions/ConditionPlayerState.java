/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerState
extends Condition {
    private final CheckPlayerState _check;
    private final boolean _required;

    public ConditionPlayerState(CheckPlayerState check, boolean required) {
        this._check = check;
        this._required = required;
    }

    @Override
    protected boolean testImpl(Env env) {
        switch (this._check) {
            case RESTING: {
                if (env.character.isPlayer()) {
                    return ((Player)env.character).isSitting() == this._required;
                }
                return !this._required;
            }
            case MOVING: {
                return env.character.getMovement().isMoving() == this._required;
            }
            case RUNNING: {
                return (env.character.getMovement().isMoving() && env.character.isRunning()) == this._required;
            }
            case STANDING: {
                if (env.character.isPlayer()) {
                    return ((Player)env.character).isSitting() != this._required && env.character.getMovement().isMoving() != this._required;
                }
                return env.character.getMovement().isMoving() != this._required;
            }
            case FLYING: {
                if (env.character.isPlayer()) {
                    return env.character.isFlying() == this._required;
                }
                return !this._required;
            }
            case FLYING_TRANSFORM: {
                if (env.character.isPlayer()) {
                    return ((Player)env.character).isInFlyingTransform() == this._required;
                }
                return !this._required;
            }
        }
        return !this._required;
    }

    public static enum CheckPlayerState {
        RESTING,
        MOVING,
        RUNNING,
        STANDING,
        FLYING,
        FLYING_TRANSFORM;

    }
}

