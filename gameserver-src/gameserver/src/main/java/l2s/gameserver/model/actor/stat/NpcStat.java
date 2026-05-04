/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.stat;

import l2s.gameserver.model.actor.stat.CreatureStat;
import l2s.gameserver.model.instances.NpcInstance;

public class NpcStat
extends CreatureStat {
    public NpcStat(NpcInstance owner) {
        super(owner);
    }

    @Override
    public NpcInstance getOwner() {
        return (NpcInstance)this._owner;
    }
}

