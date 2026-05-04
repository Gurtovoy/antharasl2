/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerIsChaotic
extends Condition {
    private final boolean _chaotic;

    public ConditionPlayerIsChaotic(boolean chaotic) {
        this._chaotic = chaotic;
    }

    @Override
    protected boolean testImpl(Env env) {
        Player player = env.character.getPlayer();
        if (player == null) {
            return !this._chaotic;
        }
        if (player.isPK()) {
            return this._chaotic;
        }
        return !this._chaotic;
    }
}

