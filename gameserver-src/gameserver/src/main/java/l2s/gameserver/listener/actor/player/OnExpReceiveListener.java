/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;
import l2s.gameserver.model.Player;

public interface OnExpReceiveListener
extends PlayerListener {
    public void onExpReceive(Player var1, long var2, boolean var4);
}

