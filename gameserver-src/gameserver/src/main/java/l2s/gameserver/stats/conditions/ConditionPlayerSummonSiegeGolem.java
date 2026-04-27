/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.entity.events.impl.CastleSiegeEvent;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerSummonSiegeGolem
extends Condition {
    @Override
    protected boolean testImpl(Env env) {
        Player player = env.character.getPlayer();
        if (player == null) {
            return false;
        }
        Zone zone = player.getZone(Zone.ZoneType.RESIDENCE);
        if (zone != null) {
            return false;
        }
        zone = player.getZone(Zone.ZoneType.SIEGE);
        if (zone == null) {
            return false;
        }
        for (SiegeEvent event : player.getEvents(SiegeEvent.class)) {
            if (!(event instanceof CastleSiegeEvent ? zone.getParams().getInteger("residence") == event.getId() && event.getSiegeClan("attackers", player.getClan()) != null : event.getSiegeClan("defenders", player.getClan()) != null)) continue;
            return true;
        }
        return false;
    }
}

