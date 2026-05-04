/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassId;

public interface OnClassChangeListener
extends PlayerListener {
    public void onClassChange(Player var1, ClassId var2, ClassId var3);
}

