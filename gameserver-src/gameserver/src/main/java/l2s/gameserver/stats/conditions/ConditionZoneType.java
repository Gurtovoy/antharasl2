/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Zone;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionZoneType
extends Condition {
    private final Zone.ZoneType _zoneType;

    public ConditionZoneType(String zoneType) {
        this._zoneType = Zone.ZoneType.valueOf(zoneType);
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        return env.character.isInZone(this._zoneType);
    }
}

