/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 */
package l2s.gameserver.model.entity.events.impl;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.SingleMatchEvent;

public abstract class AbstractDuelEvent
extends SingleMatchEvent {
    public AbstractDuelEvent(MultiValueSet<String> set) {
        super(set);
    }

    protected AbstractDuelEvent(int id, String name) {
        super(id, name);
    }

    public abstract boolean canDuel(Player var1, Player var2, boolean var3);

    public abstract void askDuel(Player var1, Player var2, int var3);

    public abstract void createDuel(Player var1, Player var2, int var3);
}

