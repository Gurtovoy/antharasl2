/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerIsHero
extends Condition {
    private final boolean _value;

    public ConditionPlayerIsHero(boolean value) {
        this._value = value;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return !this._value;
        }
        return env.character.getPlayer().isHero() == this._value;
    }
}

