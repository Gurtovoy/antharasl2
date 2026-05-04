package l2s.gameserver.model.entity.events.impl;

import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.data.BoatHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.boat.Shuttle;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventType;

public class ShuttleWayEvent
extends Event {
    private final Shuttle _shuttle;
    private final Location _nextWayLoc;
    private final TIntSet _stopIds = new TIntHashSet();
    private final int _speed;
    private final Location _returnLoc;

    public ShuttleWayEvent(MultiValueSet<String> set) {
        super(set);
        int shuttleId = set.getInteger("shuttle_id", -1);
        if (shuttleId > 0) {
            this._shuttle = BoatHolder.getInstance().initShuttle(this.getName(), shuttleId);
            Location loc = Location.parseLoc(set.getString("spawn_point"));
            this._shuttle.setLoc(loc, true);
            this._shuttle.setHeading(loc.h);
        } else {
            this._shuttle = (Shuttle)BoatHolder.getInstance().getBoat(this.getName());
        }
        this._nextWayLoc = Location.parseLoc(set.getString("next_way_loc"));
        this._stopIds.addAll(set.getIntegerArray("stop_id"));
        this._speed = set.getInteger("speed");
        this._returnLoc = Location.parseLoc(set.getString("return_point"));
        this._shuttle.addWayEvent(this);
    }

    @Override
    public void startEvent() {
        super.startEvent();
        this._shuttle.setMoveSpeed(this._speed);
        this._shuttle.setRunState(1);
        this._shuttle.broadcastCharInfo();
        this._shuttle.getMovement().moveToLocation(this._nextWayLoc.getX(), this._nextWayLoc.getY(), this._nextWayLoc.getZ(), 0, false);
    }

    @Override
    public void stopEvent(boolean force) {
        super.stopEvent(force);
        this._shuttle.setRunState(0);
        this._shuttle.broadcastCharInfo();
    }

    @Override
    public void reCalcNextTime(boolean onInit) {
        if (onInit) {
            return;
        }
        this.clearActions();
        this.registerActions();
    }

    @Override
    public EventType getType() {
        return EventType.SHUTTLE_EVENT;
    }

    @Override
    protected long startTimeMillis() {
        return System.currentTimeMillis();
    }

    @Override
    public void printInfo() {
    }

    public boolean containsStop(int stopId) {
        return this._stopIds.contains(stopId);
    }

    public Location getReturnLoc() {
        return this._returnLoc;
    }
}

