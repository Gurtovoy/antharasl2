/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;
import l2s.gameserver.model.Player;

public interface OnLevelChangeListener
extends PlayerListener {
    public void onLevelChange(Player var1, int var2, int var3);
}

