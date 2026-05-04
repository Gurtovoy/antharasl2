/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;
import l2s.gameserver.model.Player;

public interface OnQuestFinishListener
extends PlayerListener {
    public void onQuestFinish(Player var1, int var2);
}

