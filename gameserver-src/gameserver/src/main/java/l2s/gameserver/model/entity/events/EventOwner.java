/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventComparator;

public abstract class EventOwner {
    private Set<Event> _events = new ConcurrentSkipListSet<Event>(EventComparator.getInstance());

    public <E extends Event> E getEvent(Class<E> eventClass) {
        for (Event e : this._events) {
            if (e.getClass() == eventClass) {
                return (E)((Object)e);
            }
            if (!eventClass.isAssignableFrom(e.getClass())) continue;
            return (E)((Object)e);
        }
        return null;
    }

    public <E extends Event> List<E> getEvents(Class<E> eventClass) {
        ArrayList<E> events = new ArrayList<E>();
        for (Event e : this._events) {
            if (e.getClass() == eventClass) {
                events.add((E)e);
                continue;
            }
            if (!eventClass.isAssignableFrom(e.getClass())) continue;
            events.add((E)e);
        }
        return events;
    }

    public boolean containsEvent(Event event) {
        return this._events.contains(event);
    }

    public boolean containsEvent(Class<? extends Event> eventClass) {
        for (Event e : this._events) {
            if (e.getClass() == eventClass) {
                return true;
            }
            if (!eventClass.isAssignableFrom(e.getClass())) continue;
            return true;
        }
        return false;
    }

    public void addEvent(Event event) {
        this._events.add(event);
    }

    public void removeEvent(Event event) {
        this._events.remove(event);
    }

    public void removeEvents(Class<? extends Event> eventClass) {
        for (Event e : this._events) {
            if (e.getClass() == eventClass) {
                this._events.remove(e);
                continue;
            }
            if (!eventClass.isAssignableFrom(e.getClass())) continue;
            this._events.remove(e);
        }
    }

    public Set<Event> getEvents() {
        return this._events;
    }
}

