/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.ChatType;

public interface OnPlayerChatMessageReceive
extends PlayerListener {
    public void onChatMessageReceive(Player var1, ChatType var2, String var3, String var4);
}

