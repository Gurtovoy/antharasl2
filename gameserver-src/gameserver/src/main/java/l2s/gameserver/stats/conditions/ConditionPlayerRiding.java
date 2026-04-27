/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerRiding
extends Condition {
    private final CheckPlayerRiding _riding;

    public ConditionPlayerRiding(CheckPlayerRiding riding) {
        this._riding = riding;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        Player player = (Player)env.character;
        switch (this._riding) {
            case STRIDER: {
                if (!player.isMounted() || player.isFlying()) break;
                return true;
            }
            case WYVERN: {
                if (!player.isMounted() || !player.isFlying()) break;
                return true;
            }
            case NONE: {
                if (player.isMounted()) break;
                return true;
            }
        }
        return false;
    }

    public static enum CheckPlayerRiding {
        NONE,
        STRIDER,
        WYVERN;

    }
}

