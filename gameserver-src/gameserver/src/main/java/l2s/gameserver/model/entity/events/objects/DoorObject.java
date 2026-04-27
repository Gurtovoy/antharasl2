/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.InitableObject;
import l2s.gameserver.model.entity.events.objects.OpenableObject;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.instances.DoorInstance;

public class DoorObject
implements SpawnableObject,
InitableObject,
OpenableObject {
    private int _id;
    private DoorInstance _door;
    private boolean _weak;

    public DoorObject(int id) {
        this._id = id;
    }

    @Override
    public void initObject(Event e) {
        this._door = e.getReflection().getDoor(this._id);
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        this.refreshObject(event, reflection);
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
        if (reflection.isMain()) {
            this.refreshObject(event, reflection);
        }
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
        if (!event.isInProgress()) {
            this._door.removeEvent(event);
        } else {
            this._door.addEvent(event);
            this._door.broadcastStatusUpdate();
        }
        if (this._door.getCurrentHp() <= 0.0) {
            this._door.decayMe();
            this._door.spawnMe();
        }
        this._door.setCurrentHp((double)this._door.getMaxHp() * (this.isWeak() ? 0.5 : 1.0), true);
        this.closeObject(event);
    }

    public int getId() {
        return this._id;
    }

    public int getUpgradeValue() {
        return this._door.getUpgradeHp();
    }

    public void setUpgradeValue(Event event, int val) {
        this._door.setUpgradeHp(val);
        this.refreshObject(event, event.getReflection());
    }

    @Override
    public void openObject(Event e) {
        this._door.openMe(null, !e.isInProgress());
    }

    @Override
    public void closeObject(Event e) {
        this._door.closeMe(null, !e.isInProgress());
    }

    public DoorInstance getDoor() {
        return this._door;
    }

    public boolean isWeak() {
        return this._weak;
    }

    public void setWeak(boolean weak) {
        this._weak = weak;
    }
}

