/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.basestats;

import l2s.gameserver.model.Playable;
import l2s.gameserver.model.actor.basestats.CreatureBaseStats;
import l2s.gameserver.stats.Stats;

public class PlayableBaseStats
extends CreatureBaseStats {
    public PlayableBaseStats(Playable owner) {
        super(owner);
    }

    @Override
    public Playable getOwner() {
        return (Playable)this._owner;
    }

    @Override
    public double getPAtkSpd() {
        return this.getOwner().getStat().calc(Stats.BASE_P_ATK_SPD, super.getPAtkSpd(), null, null);
    }
}

