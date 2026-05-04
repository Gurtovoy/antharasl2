/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.actor.ai;

import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.listener.AiListener;
import l2s.gameserver.model.Creature;

public interface OnAiEventListener
extends AiListener {
    public void onAiEvent(Creature var1, CtrlEvent var2, Object[] var3);
}

