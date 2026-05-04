package l2s.gameserver.model.entity.events;

import java.util.Comparator;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventType;

public class EventComparator
implements Comparator<Event> {
    private static final EventComparator _instance = new EventComparator();

    public static EventComparator getInstance() {
        return _instance;
    }

    @Override
    public int compare(Event o1, Event o2) {
        EventType type2;
        EventType type1 = o1.getType();
        if (type1 == (type2 = o2.getType())) {
            return o1.hashCode() - o2.hashCode();
        }
        return type1.ordinal() - type2.ordinal();
    }
}

