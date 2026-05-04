package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventType;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;

public final class EventHolder
extends AbstractHolder {
    private static final EventHolder _instance = new EventHolder();
    private final IntObjectMap<Event> _events = new TreeIntObjectMap();

    public static EventHolder getInstance() {
        return _instance;
    }

    public void addEvent(Event event) {
        this._events.put(EventHolder.getHash(event.getType(), event.getId()), event);
    }

    public <E extends Event> E getEvent(EventType type, int id) {
        return (E)this._events.get(EventHolder.getHash(type, id));
    }

    @SuppressWarnings("unchecked")
    public <E extends Event> List<E> getEvents(EventType type) {
        ArrayList<Event> events = new ArrayList<Event>();
        for (Event e : this._events.valueCollection()) {
            if (e.getType() != type) continue;
            events.add(e);
        }
        return (List<E>)(List<?>)events;
    }

    @SuppressWarnings("unchecked")
    public <E extends Event> List<E> getEvents(Class<E> eventClass) {
        ArrayList<Event> events = new ArrayList<Event>();
        for (Event e : this._events.valueCollection()) {
            if (e.getClass() == eventClass) {
                events.add(e);
                continue;
            }
            if (!eventClass.isAssignableFrom(e.getClass())) continue;
            events.add(e);
        }
        return (List<E>)(List<?>)events;
    }

    public void findEvent(Player player) {
        for (Event event : this._events.valueCollection()) {
            event.findEvent(player);
        }
    }

    public void callInit() {
        for (Event event : this._events.valueCollection()) {
            event.initEvent();
        }
    }

    private static int getHash(EventType type, int id) {
        return type.ordinal() * 100000 + id;
    }

    public int size() {
        return this._events.size();
    }

    public void clear() {
        this._events.clear();
    }
}

