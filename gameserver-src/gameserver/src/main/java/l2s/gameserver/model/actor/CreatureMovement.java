/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.reference.HardReference
 *  l2s.commons.lang.reference.HardReferences
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.actor;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geodata.GeoMove;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.listener.actions.OnArrivedAction;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectTasks;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.PositionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CreatureMovement {
    private static final Logger _log = LoggerFactory.getLogger(CreatureMovement.class);
    private final Creature _actor;
    private final Lock _moveLock = new ReentrantLock();
    private final Location _movingDestTempPos = new Location();
    private final List<List<Location>> _targetRecorder = new ArrayList<List<Location>>();
    private volatile HardReference<? extends Creature> _followTarget = HardReferences.emptyRef();
    private boolean _isMoving;
    private boolean _isKeyboardMoving;
    private boolean _isPathfindMoving;
    private OnArrivedAction _onArrivedAction;
    private boolean _isFollow;
    private boolean _forestalling;
    private Future<?> _moveTask;
    private double _moveTaskAllDist;
    private double _moveTaskDoneDist;
    private List<Location> _moveList;
    private Location _destination;
    private int _moveOffset;
    private int _followCounter;
    private int _previousSpeed = 0;
    private long _followTimestamp;
    private long _startMoveTime;

    public CreatureMovement(Creature actor) {
        this._actor = actor;
    }

    public Lock getMoveLock() {
        return this._moveLock;
    }

    public boolean isMoving() {
        return this._isMoving;
    }

    public boolean isKeyboardMoving() {
        return this._isKeyboardMoving;
    }

    public boolean isPathfindMoving() {
        return this._isPathfindMoving;
    }

    public boolean isFollow() {
        return this._isFollow;
    }

    public int getMoveOffset() {
        return this._moveOffset;
    }

    public void setMoveOffset(int value) {
        this._moveOffset = value;
    }

    public Location getDestination() {
        if (this._destination == null) {
            return new Location(0, 0, 0);
        }
        return this._destination;
    }

    public int getMoveTickInterval() {
        return (this._actor.isPlayer() && !this._actor.isVisualTransformed() ? 16000 : 32000) / Math.max(this._actor.getMoveSpeed(), 1);
    }

    public Creature getFollowTarget() {
        return (Creature)this._followTarget.get();
    }

    public void setFollowTarget(Creature target) {
        this._followTarget = target == null ? HardReferences.emptyRef() : target.getRef();
    }

    public void setMoveTaskDist(double dist) {
        this._moveTaskAllDist = dist;
        this._moveTaskDoneDist = 0.0;
    }

    public Location getIntersectionPoint(Creature target) {
        if (!PositionUtils.isFacing(this._actor, target, 90)) {
            return new Location(target.getX(), target.getY(), target.getZ());
        }
        double angle = PositionUtils.convertHeadingToDegree(target.getHeading());
        double radian = Math.toRadians(angle - 90.0);
        double range = target.getMoveSpeed() / 2;
        return new Location((int)((double)target.getX() - range * Math.sin(radian)), (int)((double)target.getY() + range * Math.cos(radian)), target.getZ());
    }

    private Location setSimplePath(Location dest) {
        List<Location> _moveList = GeoMove.constructMoveList(this._actor.getLoc(), dest);
        if (_moveList.isEmpty()) {
            return null;
        }
        this._targetRecorder.clear();
        this._targetRecorder.add(_moveList);
        return _moveList.get(_moveList.size() - 1);
    }

    private void moveNext(boolean firstMove) {
        int distance;
        Location dest;
        if (!this.isMoving() || this._actor.isMovementDisabled()) {
            this.stopMove();
            return;
        }
        this._previousSpeed = this._actor.getMoveSpeed();
        if (this._previousSpeed <= 0) {
            this.stopMove();
            return;
        }
        if (!firstMove && (dest = this._destination.clone()) != null) {
            this._actor.setLoc(dest, true);
            this._actor.getListeners().onMove(dest);
        }
        if (this._targetRecorder.isEmpty()) {
            boolean follow = this.isFollow();
            CtrlEvent ctrlEvent = follow ? CtrlEvent.EVT_ARRIVED_TARGET : CtrlEvent.EVT_ARRIVED;
            OnArrivedAction onArrivedAction = this._onArrivedAction;
            this.stopMove(false);
            if (onArrivedAction != null) {
                onArrivedAction.onArrived(this._actor, this._actor.getLoc(), follow);
            }
            ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(this._actor, ctrlEvent));
            return;
        }
        this._moveList = this._targetRecorder.remove(0);
        Location begin = this._moveList.get(0).clone().geo2world();
        Location end = this._moveList.get(this._moveList.size() - 1).clone().geo2world();
        if (!(this._actor.isFlying() || this._actor.isInBoat() || this._actor.isInWater() || this._actor.isBoat() || GeoEngine.canMoveToCoord(this._actor.getX(), this._actor.getY(), this._actor.getZ(), end.x, end.y, end.z, this._actor.getGeoIndex()))) {
            this.stopMove();
            return;
        }
        this._destination = end;
        int n = distance = this._actor.isFlying() || this._actor.isInWater() ? begin.getDistance3D(end) : begin.getDistance(end);
        if (distance != 0) {
            this._actor.setHeading(PositionUtils.calculateHeadingFrom(begin.x, begin.y, this._destination.x, this._destination.y));
        }
        this.setMoveTaskDist(distance);
        this._actor.broadcastMove();
        this._startMoveTime = this._followTimestamp = System.currentTimeMillis();
        this._moveTask = ThreadPoolManager.getInstance().schedule(this::updatePosition, this.getMoveTickInterval());
    }

    private Location buildPathTo(int x, int y, int z, int offset, boolean pathFind) {
        return this.buildPathTo(x, y, z, offset, null, false, pathFind);
    }

    private Location buildPathTo(int x, int y, int z, int offset, Creature follow, boolean forestalling, boolean pathFind) {
        List<List<Location>> targets;
        int geoIndex = this._actor.getGeoIndex();
        Location dest = forestalling && follow != null && follow.getMovement().isMoving() ? this.getIntersectionPoint(follow) : new Location(x, y, z);
        if (this._actor.isInBoat() || this._actor.isBoat() || !Config.ALLOW_GEODATA) {
            PositionUtils.applyOffset(this._actor, dest, offset);
            return this.setSimplePath(dest);
        }
        if (this._actor.isFlying() || this._actor.isInWater()) {
            PositionUtils.applyOffset(this._actor, dest, offset);
            if (this._actor.isFlying()) {
                if (GeoEngine.canSeeCoord(this._actor, dest.x, dest.y, dest.z, true)) {
                    return this.setSimplePath(dest);
                }
                Location nextloc = this._actor.isObservePoint() ? GeoEngine.moveInWaterCheck(this._actor, dest.x, dest.y, dest.z, new int[]{Integer.MIN_VALUE, Integer.MAX_VALUE}) : GeoEngine.moveCheckInAir(this._actor, dest.x, dest.y, dest.z);
                if (nextloc != null && !nextloc.equals(this._actor.getX(), this._actor.getY(), this._actor.getZ())) {
                    return this.setSimplePath(nextloc);
                }
            } else {
                int dz;
                Location nextloc = GeoEngine.moveInWaterCheck(this._actor, dest.x, dest.y, dest.z, this._actor.getWaterZ());
                if (nextloc == null) {
                    return null;
                }
                List<Location> _moveList = GeoMove.constructMoveList(this._actor.getLoc(), nextloc.clone());
                this._targetRecorder.clear();
                if (!_moveList.isEmpty()) {
                    this._targetRecorder.add(_moveList);
                }
                if ((dz = dest.z - nextloc.z) > 0 && dz < 128 && (_moveList = GeoEngine.MoveList(nextloc.x, nextloc.y, nextloc.z, dest.x, dest.y, geoIndex, false)) != null && !_moveList.isEmpty()) {
                    this._targetRecorder.add(_moveList);
                }
                if (!_moveList.isEmpty()) {
                    return _moveList.get(_moveList.size() - 1);
                }
            }
            return null;
        }
        List<Location> _moveList = GeoEngine.MoveList(this._actor.getX(), this._actor.getY(), this._actor.getZ(), dest.x, dest.y, geoIndex, true);
        if (_moveList != null) {
            if (_moveList.size() < 2) {
                return null;
            }
            PositionUtils.applyOffset(_moveList, offset);
            if (_moveList.size() < 2) {
                return null;
            }
            this._targetRecorder.clear();
            this._targetRecorder.add(_moveList);
            return _moveList.get(_moveList.size() - 1);
        }
        if ((pathFind || this._actor.isFakePlayer()) && !(targets = GeoMove.findMovePath(this._actor.getX(), this._actor.getY(), this._actor.getZ(), dest.getX(), dest.getY(), dest.getZ(), this._actor, geoIndex)).isEmpty()) {
            _moveList = targets.remove(targets.size() - 1);
            PositionUtils.applyOffset(_moveList, offset);
            if (!_moveList.isEmpty()) {
                targets.add(_moveList);
            }
            if (!targets.isEmpty()) {
                this._targetRecorder.clear();
                this._targetRecorder.addAll(targets);
                for (int i = targets.size() - 1; i >= 0; --i) {
                    List<Location> target = targets.get(i);
                    if (target.isEmpty()) continue;
                    this._isPathfindMoving = true;
                    return target.get(target.size() - 1);
                }
                if (pathFind) {
                    return null;
                }
            }
        }
        if (!this._actor.isFakePlayer() || !pathFind) {
            PositionUtils.applyOffset(this._actor, dest, offset);
            _moveList = GeoEngine.MoveList(this._actor.getX(), this._actor.getY(), this._actor.getZ(), dest.x, dest.y, geoIndex, false);
            if (_moveList != null && _moveList.size() > 1) {
                this._targetRecorder.clear();
                this._targetRecorder.add(_moveList);
                return _moveList.get(_moveList.size() - 1);
            }
        }
        return null;
    }

    public boolean followToCharacter(Creature target, int offset, boolean forestalling) {
        return this.followToCharacter(target.getLoc(), target, offset, forestalling);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean followToCharacter(Location loc, Creature target, int offset, boolean forestalling) {
        this.getMoveLock().lock();
        try {
            if (this._actor.isMovementDisabled() || target == null || this._actor.isInBoat() && !this._actor.isInShuttle() || target.isInvisible(this._actor)) {
                boolean bl = false;
                return bl;
            }
            if (this._actor.getReflection() != target.getReflection()) {
                boolean bl = false;
                return bl;
            }
            if (this._actor.getDistance(target) > 5000) {
                boolean bl = false;
                return bl;
            }
            offset = Math.max(offset, 10);
            if (this.isFollow() && target == this.getFollowTarget() && offset == this.getMoveOffset()) {
                boolean bl = true;
                return bl;
            }
            if (Math.abs(this._actor.getZ() - target.getZ()) > 1000 && !this._actor.isFlying()) {
                boolean bl = false;
                return bl;
            }
            this._actor.getAI().clearNextAction();
            this.stopMove(false);
            this._actor.deactivateGeoControl();
            if (this.buildPathTo(loc.x, loc.y, loc.z, 0, target, forestalling, !target.isDoor()) == null) {
                this._actor.activateGeoControl();
                boolean bl = false;
                return bl;
            }
            this._movingDestTempPos.set(loc.x, loc.y, loc.z);
            this._isMoving = true;
            this._isKeyboardMoving = false;
            this._isFollow = true;
            this._forestalling = forestalling;
            this.setMoveOffset(offset);
            this._followCounter = 0;
            this.setFollowTarget(target);
            this.moveNext(true);
            boolean bl = true;
            return bl;
        }
        finally {
            this.getMoveLock().unlock();
        }
    }

    public boolean moveToLocation(Location loc, int offset, boolean pathfinding) {
        return this.moveToLocation(loc.x, loc.y, loc.z, offset, pathfinding, true, false, -1);
    }

    public boolean moveToLocation(Location loc, int offset, boolean pathfinding, OnArrivedAction onArrivedAction) {
        return this.moveToLocation(loc.x, loc.y, loc.z, offset, pathfinding, true, false, -1, onArrivedAction);
    }

    public boolean moveToLocation(Location loc, int offset, boolean pathfinding, int maxDestRange) {
        return this.moveToLocation(loc.x, loc.y, loc.z, offset, pathfinding, true, false, maxDestRange);
    }

    public boolean moveToLocation(Location loc, int offset, boolean pathfinding, boolean cancelNextAction, boolean keyboard) {
        return this.moveToLocation(loc.x, loc.y, loc.z, offset, pathfinding, cancelNextAction, keyboard, -1);
    }

    public boolean moveToLocation(int x_dest, int y_dest, int z_dest, int offset, boolean pathfinding) {
        return this.moveToLocation(x_dest, y_dest, z_dest, offset, pathfinding, true, false, -1);
    }

    public boolean moveToLocation(int x_dest, int y_dest, int z_dest, int offset, boolean pathfinding, boolean cancelNextAction, boolean keyboard) {
        return this.moveToLocation(x_dest, y_dest, z_dest, offset, pathfinding, cancelNextAction, keyboard, -1);
    }

    public boolean moveToLocation(int x_dest, int y_dest, int z_dest, int offset, boolean pathfinding, boolean cancelNextAction, boolean keyboard, int maxDestRange) {
        return this.moveToLocation(x_dest, y_dest, z_dest, offset, pathfinding, cancelNextAction, keyboard, maxDestRange, null);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean moveToLocation(int x_dest, int y_dest, int z_dest, int offset, boolean pathfinding, boolean cancelNextAction, boolean keyboard, int maxDestRange, OnArrivedAction onArrivedAction) {
        this.getMoveLock().lock();
        try {
            offset = Math.max(offset, 0);
            Location dst_geoloc = new Location(x_dest, y_dest, z_dest).world2geo();
            if (this.isMoving() && !this.isFollow() && this._movingDestTempPos.equals(dst_geoloc)) {
                this._actor.sendActionFailed();
                boolean bl = true;
                return bl;
            }
            if (this._actor.isMovementDisabled()) {
                this._actor.getAI().setNextAction(PlayableAI.AINextAction.MOVE, new Location(x_dest, y_dest, z_dest), offset, pathfinding && !keyboard, false);
                this._actor.sendActionFailed();
                boolean bl = false;
                return bl;
            }
            this._actor.getAI().clearNextAction();
            if (this._actor.isPlayer() && cancelNextAction) {
                this._actor.getAI().changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            }
            this.stopMove(false);
            this._actor.deactivateGeoControl();
            dst_geoloc = this.buildPathTo(x_dest, y_dest, z_dest, offset, pathfinding && !keyboard);
            if (dst_geoloc != null) {
                if (maxDestRange == -1) {
                    this._movingDestTempPos.set(dst_geoloc);
                } else {
                    Location dst_loc = dst_geoloc.geo2world();
                    if (!PositionUtils.checkIfInRange(maxDestRange + offset, x_dest, y_dest, z_dest, dst_loc.x, dst_loc.y, dst_loc.z, true)) {
                        this._actor.activateGeoControl();
                        this._actor.sendActionFailed();
                        boolean bl = false;
                        return bl;
                    }
                    this._movingDestTempPos.set(dst_geoloc);
                }
            } else {
                this._actor.activateGeoControl();
                this._actor.sendActionFailed();
                boolean bl = false;
                return bl;
            }
            this._isMoving = true;
            this._isKeyboardMoving = keyboard;
            this._onArrivedAction = onArrivedAction;
            this.moveNext(true);
            boolean bl = true;
            return bl;
        }
        finally {
            this.getMoveLock().unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean updatePosition() {
        this.getMoveLock().lock();
        try {
            Location followLoc;
            if (!this.isMoving()) {
                boolean bl = false;
                return bl;
            }
            if (this._actor.isMovementDisabled()) {
                this.stopMove();
                boolean bl = false;
                return bl;
            }
            int speed = this._actor.getMoveSpeed();
            if (speed <= 0) {
                this.stopMove();
                boolean bl = false;
                return bl;
            }
            Creature follow = null;
            if (this.isFollow()) {
                follow = this.getFollowTarget();
                if (follow == null || follow.isInvisible(this._actor)) {
                    this.stopMove();
                    boolean bl = false;
                    return bl;
                }
                if (this._actor.isInRangeZ(follow, this.getMoveOffset()) && GeoEngine.canSeeTarget(this._actor, follow)) {
                    OnArrivedAction onArrivedAction = this._onArrivedAction;
                    this.stopMove();
                    if (onArrivedAction != null) {
                        onArrivedAction.onArrived(this._actor, this._actor.getLoc(), true);
                    }
                    ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(this._actor, CtrlEvent.EVT_ARRIVED_TARGET));
                    boolean bl = false;
                    return bl;
                }
            }
            if (this._moveTaskAllDist <= 0.0) {
                this.moveNext(false);
                boolean onArrivedAction = true;
                return onArrivedAction;
            }
            long now = System.currentTimeMillis();
            this._moveTaskDoneDist += (double)((now - this._startMoveTime) * (long)this._previousSpeed) / 1000.0;
            double done = Math.max(0.0, this._moveTaskDoneDist / this._moveTaskAllDist);
            if (done >= 1.0) {
                this.moveNext(false);
                boolean bl = true;
                return bl;
            }
            if (this._actor.isMovementDisabled()) {
                this.stopMove();
                boolean bl = false;
                return bl;
            }
            int index = Math.max(0, Math.min(this._moveList.size() - 1, (int)((double)this._moveList.size() * done)));
            Location loc = this._moveList.get(index).clone().geo2world();
            if (!(this._actor.isFlying() || this._actor.isInBoat() || this._actor.isInWater() || this._actor.isBoat() || loc.z - this._actor.getZ() <= 256)) {
                String bug_text = "geo bug 1 at: " + this._actor.getLoc() + " => " + loc.x + "," + loc.y + "," + loc.z + "\tAll path: " + this._moveList.get(0) + " => " + this._moveList.get(this._moveList.size() - 1);
                Log.add(bug_text, "geo");
                this.stopMove();
                boolean bl = false;
                return bl;
            }
            if (loc == null || this._actor.isMovementDisabled()) {
                this.stopMove();
                boolean bug_text = false;
                return bug_text;
            }
            this._actor.setLoc(loc, true);
            if (this._actor.isMovementDisabled()) {
                this.stopMove();
                boolean bug_text = false;
                return bug_text;
            }
            if (this.isFollow() && this._movingDestTempPos.getDistance3D(followLoc = follow.getLoc()) != 0) {
                ++this._followCounter;
                if (Math.abs(this._actor.getZ() - loc.z) > 1000 && !this._actor.isFlying()) {
                    this._actor.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
                    this.stopMove();
                    boolean bl = false;
                    return bl;
                }
                if (this._followCounter == 5) {
                    if (this.buildPathTo(followLoc.x, followLoc.y, followLoc.z, 0, follow, this._forestalling, !follow.isDoor()) == null) {
                        this.stopMove();
                        boolean bl = false;
                        return bl;
                    }
                    this._movingDestTempPos.set(followLoc.x, followLoc.y, followLoc.z);
                    this.moveNext(true);
                    this._followCounter = 0;
                    boolean bl = true;
                    return bl;
                }
            }
            this._previousSpeed = speed;
            this._startMoveTime = now;
            this._moveTask = ThreadPoolManager.getInstance().schedule(this::updatePosition, this.getMoveTickInterval());
            boolean bl = true;
            return bl;
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
            boolean bl = false;
            return bl;
        }
        finally {
            this.getMoveLock().unlock();
        }
    }

    public void stopMove() {
        this.stopMove(true);
    }

    public void stopMove(boolean stop) {
        if (!this.isMoving()) {
            return;
        }
        this.getMoveLock().lock();
        try {
            if (!this.isMoving()) {
                return;
            }
            this._isMoving = false;
            this._isKeyboardMoving = false;
            this._isFollow = false;
            this._isPathfindMoving = false;
            this._onArrivedAction = null;
            if (this._moveTask != null) {
                this._moveTask.cancel(false);
                this._moveTask = null;
            }
            this._destination = null;
            this._moveList = null;
            this._targetRecorder.clear();
            if (stop) {
                this._actor.broadcastStopMove();
            }
            this._actor.activateGeoControl();
        }
        finally {
            this.getMoveLock().unlock();
        }
    }
}

