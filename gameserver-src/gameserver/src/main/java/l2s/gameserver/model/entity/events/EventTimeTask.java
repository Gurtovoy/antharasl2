/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events;

import l2s.gameserver.model.entity.events.Event;

public class EventTimeTask
implements Runnable {
    private final Event _event;
    private final int _time;

    public EventTimeTask(Event event, int time) {
        this._event = event;
        this._time = time;
    }

    @Override
    public void run() {
        this._event.timeActions(this._time);
    }
}

