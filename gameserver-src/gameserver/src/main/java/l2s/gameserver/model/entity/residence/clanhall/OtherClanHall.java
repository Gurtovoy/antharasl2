/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.residence.clanhall;

import l2s.gameserver.model.entity.residence.ClanHallType;
import l2s.gameserver.model.entity.residence.clanhall.NormalClanHall;
import l2s.gameserver.templates.StatsSet;

public class OtherClanHall
extends NormalClanHall {
    public OtherClanHall(StatsSet set) {
        super(set);
    }

    @Override
    public ClanHallType getClanHallType() {
        return ClanHallType.OTHER;
    }
}

