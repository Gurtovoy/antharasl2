/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerClassId
extends Condition {
    private final int[] _classIds;

    public ConditionPlayerClassId(String[] ids) {
        this._classIds = new int[ids.length];
        for (int i = 0; i < ids.length; ++i) {
            this._classIds[i] = Integer.parseInt(ids[i]);
        }
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        int playerClassId = env.character.getPlayer().getActiveClassId();
        for (int id : this._classIds) {
            if (playerClassId != id) continue;
            return true;
        }
        return false;
    }
}

