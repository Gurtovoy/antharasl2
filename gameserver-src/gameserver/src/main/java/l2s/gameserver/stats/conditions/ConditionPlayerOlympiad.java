/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerOlympiad
extends Condition {
    private final boolean _value;

    public ConditionPlayerOlympiad(boolean v) {
        this._value = v;
    }

    @Override
    protected boolean testImpl(Env env) {
        Player player = env.character.getPlayer();
        if (player != null) {
            return player.isInOlympiadMode() == this._value;
        }
        return !this._value;
    }
}

