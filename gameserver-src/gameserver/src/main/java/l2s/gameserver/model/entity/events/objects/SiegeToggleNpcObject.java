/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.objects;

import java.util.Set;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.instances.residences.SiegeToggleNpcInstance;

public class SiegeToggleNpcObject
implements SpawnableObject {
    private SiegeToggleNpcInstance _toggleNpc;
    private Location _location;

    public SiegeToggleNpcObject(int id, int fakeNpcId, Location loc, int hp, Set<String> set) {
        this._location = loc;
        this._toggleNpc = (SiegeToggleNpcInstance)NpcHolder.getInstance().getTemplate(id).getNewInstance();
        this._toggleNpc.initFake(fakeNpcId);
        this._toggleNpc.setMaxHp(hp);
        this._toggleNpc.setZoneList(set);
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        this._toggleNpc.decayFake();
        if (event.isInProgress()) {
            this._toggleNpc.addEvent(event);
        } else {
            this._toggleNpc.removeEvent(event);
        }
        this._toggleNpc.setCurrentHp(this._toggleNpc.getMaxHp(), true);
        this._toggleNpc.spawnMe(this._location);
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
        this._toggleNpc.removeEvent(event);
        this._toggleNpc.decayFake();
        this._toggleNpc.decayMe();
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
        this._toggleNpc.decayFake();
        if (!event.isInProgress()) {
            this._toggleNpc.removeEvent(event);
        } else {
            this._toggleNpc.addEvent(event);
        }
        if (this._toggleNpc.getCurrentHp() <= 0.0) {
            this._toggleNpc.decayMe();
            this._toggleNpc.spawnMe(this._location);
        }
        this._toggleNpc.setCurrentHp(this._toggleNpc.getMaxHp(), true);
    }

    public SiegeToggleNpcInstance getToggleNpc() {
        return this._toggleNpc;
    }

    public boolean isAlive() {
        return this._toggleNpc.isVisible();
    }
}

