/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.base.FenceState;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.InitableObject;
import l2s.gameserver.model.entity.events.objects.OpenableObject;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.instances.FenceInstance;
import l2s.gameserver.utils.FenceUtils;

public class FenceObject
implements SpawnableObject,
InitableObject,
OpenableObject {
    private final Location _loc;
    private final int _width;
    private final int _length;
    private final int _height;
    private FenceInstance _fence;

    public FenceObject(Location loc, int width, int length, int height) {
        this._loc = loc;
        this._width = width;
        this._length = length;
        this._height = height;
    }

    @Override
    public void initObject(Event e) {
        this._fence = FenceUtils.initFence("Event Fence: " + e.getName() + " " + this.hashCode(), this._loc.getX(), this._loc.getY(), this._loc.getZ(), this._width, this._length, this._height, FenceState.HIDDEN);
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        if (!event.isInProgress()) {
            this._fence.removeEvent(event);
        } else {
            this._fence.addEvent(event);
        }
        this._fence.setReflection(reflection);
        this._fence.spawnMe(this._loc);
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
        this._fence.decayMe();
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
        this._fence.decayMe();
        this._fence.setReflection(reflection);
        this._fence.spawnMe(this._loc);
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
        if (!event.isInProgress()) {
            this._fence.removeEvent(event);
        } else {
            this._fence.addEvent(event);
        }
        this._fence.setState(FenceState.HIDDEN);
    }

    @Override
    public void openObject(Event e) {
        this._fence.setState(FenceState.OPENED);
    }

    @Override
    public void closeObject(Event e) {
        this._fence.setState(FenceState.CLOSED);
    }

    public FenceInstance getFence() {
        return this._fence;
    }
}

