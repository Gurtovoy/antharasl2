/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.actor.stat;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.stat.CreatureStat;

public class PlayerStat
extends CreatureStat {
    public PlayerStat(Player owner) {
        super(owner);
    }

    @Override
    public Player getOwner() {
        return (Player)this._owner;
    }
}

