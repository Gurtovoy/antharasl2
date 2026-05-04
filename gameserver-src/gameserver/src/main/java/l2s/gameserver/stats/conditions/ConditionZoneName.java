/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionZoneName
extends Condition {
    private final String _zoneName;

    public ConditionZoneName(String zoneName) {
        this._zoneName = zoneName;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        return env.character.isInZone(this._zoneName);
    }
}

