package l2s.gameserver.model.actor.flags.flag;

import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;

public class DefaultFlag {
    private final AtomicBoolean _state = new AtomicBoolean(false);
    private final Set<Object> _statusesOwners = new HashSet<Object>();

    public boolean get() {
        return this._state.get() || !this._statusesOwners.isEmpty();
    }

    public boolean start(Object owner) {
        return this._statusesOwners.add(owner);
    }

    public boolean start() {
        return this._state.compareAndSet(false, true);
    }

    public boolean stop(Object owner) {
        return this._statusesOwners.remove(owner);
    }

    public boolean stop() {
        return this._state.compareAndSet(true, false);
    }

    public void clear() {
        this._state.set(false);
        this._statusesOwners.clear();
    }
}

