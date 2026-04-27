/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.utils;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Zone;

public class ZoneUtils {
    public static boolean checkAliveMonstersInZone(Zone zone, int npcId) {
        for (Creature c : zone.getObjects()) {
            if (!c.isMonster() || npcId != -1 && c.getNpcId() != npcId || c.isDead()) continue;
            return true;
        }
        return false;
    }

    public static boolean checkAliveMonstersInZone(Zone zone) {
        return ZoneUtils.checkAliveMonstersInZone(zone, -1);
    }
}

