/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.event;

import l2s.gameserver.listener.EventListener;
import l2s.gameserver.model.entity.events.Event;

public interface OnStartStopListener
extends EventListener {
    public void onStart(Event var1);

    public void onStop(Event var1);
}

