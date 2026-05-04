/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.Config;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerMaxSP
extends Condition {
    private final int _spToAdd;

    public ConditionPlayerMaxSP(int spToAdd) {
        this._spToAdd = spToAdd;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        long sp = env.character.getPlayer().getSp() + (long)this._spToAdd;
        return sp <= Config.SP_LIMIT;
    }
}

