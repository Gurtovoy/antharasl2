/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.objects;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventAction;

public class TaskObject {
    private final boolean _fixedRate;
    private final int _initialDelay;
    private final int _delay;
    private final Map<Event, List<ScheduledFuture<?>>> _scheduledTasks = new HashMap(0);
    private List<EventAction> _actions = Collections.emptyList();

    public TaskObject(boolean fixedRate, int initialDelay, int delay) {
        this._fixedRate = fixedRate;
        this._initialDelay = initialDelay;
        this._delay = delay;
    }

    public void setActions(List<EventAction> actions) {
        this._actions = actions;
    }

    public ScheduledFuture<?> schedule(Event event) {
        ScheduledFuture<?> task = this._fixedRate ? ThreadPoolManager.getInstance().scheduleAtFixedRate(new Task(event), this._initialDelay, this._delay) : ThreadPoolManager.getInstance().schedule(new Task(event), this._delay);
        List<ScheduledFuture<?>> tasks = this._scheduledTasks.get(event);
        if (tasks == null) {
            tasks = new ArrayList();
            this._scheduledTasks.put(event, tasks);
        }
        tasks.add(task);
        return task;
    }

    public boolean cancel(Event event) {
        List<ScheduledFuture<?>> tasks = this._scheduledTasks.remove(event);
        if (tasks != null) {
            for (ScheduledFuture<?> task : tasks) {
                task.cancel(false);
            }
            tasks.clear();
            return true;
        }
        return false;
    }

    public boolean cancel(Event event, ScheduledFuture<?> task) {
        List<ScheduledFuture<?>> tasks = this._scheduledTasks.remove(event);
        if (tasks != null && tasks.remove(task)) {
            task.cancel(false);
            return true;
        }
        return false;
    }

    private class Task
    implements Runnable {
        private final Event _event;

        public Task(Event event) {
            this._event = event;
        }

        @Override
        public void run() {
            for (EventAction action : TaskObject.this._actions) {
                action.call(this._event);
            }
        }
    }
}

