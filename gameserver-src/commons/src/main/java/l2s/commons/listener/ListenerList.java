package l2s.commons.listener;

import java.util.Collection;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import l2s.commons.listener.Listener;

public class ListenerList<T>
implements Iterable<Listener<T>> {
    protected Set<Listener<T>> listeners = new CopyOnWriteArraySet<Listener<T>>();

    public Collection<Listener<T>> getListeners() {
        return this.listeners;
    }

    @Override
    public Iterator<Listener<T>> iterator() {
        return this.listeners.iterator();
    }

    public boolean add(Listener<T> listener) {
        return this.listeners.add(listener);
    }

    public boolean remove(Listener<T> listener) {
        return this.listeners.remove(listener);
    }
}

