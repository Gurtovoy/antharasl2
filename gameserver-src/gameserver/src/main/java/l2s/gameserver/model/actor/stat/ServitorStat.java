/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.stat;

import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.actor.stat.CreatureStat;

public class ServitorStat
extends CreatureStat {
    public ServitorStat(Servitor owner) {
        super(owner);
    }

    @Override
    public Servitor getOwner() {
        return (Servitor)this._owner;
    }
}

