/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.ObservePoint;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Reflection;

public abstract class ObservableArena {
    private final List<ObservePoint> _observers = new CopyOnWriteArrayList<ObservePoint>();

    public abstract Reflection getReflection();

    public abstract Location getObserverEnterPoint(Player var1);

    public abstract boolean showObservableArenasList(Player var1);

    public void onAppearObserver(ObservePoint observer) {
    }

    public void onAddObserver(ObservePoint observer) {
    }

    public void onRemoveObserver(ObservePoint observer) {
    }

    public void onEnterObserverArena(Player player) {
    }

    public void onChangeObserverArena(Player player) {
    }

    public void onExitObserverArena(Player player) {
    }

    public final List<ObservePoint> getObservers() {
        return this._observers;
    }

    public final void addObserver(ObservePoint observer) {
        if (this._observers.add(observer)) {
            this.onAddObserver(observer);
        }
    }

    public final void removeObserver(ObservePoint observer) {
        if (this._observers.remove(observer)) {
            this.onRemoveObserver(observer);
        }
    }

    public final void clearObservers() {
        for (ObservePoint observer : this._observers) {
            Player player = observer.getPlayer();
            if (!player.isInObserverMode()) continue;
            player.leaveObserverMode();
        }
        this._observers.clear();
    }
}

