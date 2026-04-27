/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.listener.actor;

import l2s.gameserver.listener.CharListener;
import l2s.gameserver.model.Creature;

public interface OnKillListener
extends CharListener {
    public void onKill(Creature var1, Creature var2);

    public boolean ignorePetOrSummon();
}

