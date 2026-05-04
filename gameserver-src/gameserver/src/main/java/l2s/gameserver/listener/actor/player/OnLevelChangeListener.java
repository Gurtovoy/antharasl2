/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;
import l2s.gameserver.model.Player;

public interface OnLevelChangeListener
extends PlayerListener {
    public void onLevelChange(Player var1, int var2, int var3);
}

