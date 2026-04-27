/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Reflection;

public interface OnTeleportListener
extends PlayerListener {
    public void onTeleport(Player var1, int var2, int var3, int var4, Reflection var5);
}

