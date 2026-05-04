/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.actor.ai;

import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.listener.AiListener;
import l2s.gameserver.model.Creature;

public interface OnAiIntentionListener
extends AiListener {
    public void onAiIntention(Creature var1, CtrlIntention var2, Object var3, Object var4);
}

