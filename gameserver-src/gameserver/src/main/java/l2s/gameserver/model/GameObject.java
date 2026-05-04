package l2s.gameserver.model;

import gnu.trove.map.TIntObjectMap;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.geometry.Shape;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.gameserver.Config;
import l2s.gameserver.geodata.GeoControl;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.WorldRegion;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventOwner;
import l2s.gameserver.network.l2.s2c.DeleteObjectPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.Util;
import org.napile.primitive.pair.ByteObjectPair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class GameObject
extends EventOwner
implements GeoControl,
ILocation {
    private static final Logger _log = LoggerFactory.getLogger(GameObject.class);
    public static final GameObject[] EMPTY_L2OBJECT_ARRAY = new GameObject[0];
    protected static final int CREATED = 0;
    protected static final int VISIBLE = 1;
    protected static final int DELETED = -1;
    protected int objectId;
    private int _x;
    private int _y;
    private int _z;
    protected Reflection _reflection = ReflectionManager.MAIN;
    private WorldRegion _currentRegion;
    private final AtomicInteger _state = new AtomicInteger(0);
    private Shape _geoShape;
    private TIntObjectMap<ByteObjectPair<GeoEngine.CeilGeoControlType>> _geoAround;
    private int _geoControlIndex = -1;
    private final Lock _geoLock = new ReentrantLock();

    protected GameObject() {
    }

    public GameObject(int objectId) {
        this.objectId = objectId;
    }

    public HardReference<? extends GameObject> getRef() {
        return HardReferences.emptyRef();
    }

    private void clearRef() {
        HardReference<? extends GameObject> reference = this.getRef();
        if (reference != null) {
            reference.clear();
        }
    }

    public Reflection getReflection() {
        return this._reflection;
    }

    public int getReflectionId() {
        return this._reflection.getId();
    }

    public int getGeoIndex() {
        return this._reflection.isCollapseStarted() ? 0 : this._reflection.getGeoIndex();
    }

    public boolean setReflection(Reflection reflection) {
        if (this._reflection == reflection) {
            return true;
        }
        if (reflection.isCollapseStarted()) {
            return false;
        }
        boolean respawn = false;
        if (this.isVisible()) {
            this.decayMe();
            respawn = true;
        }
        this._reflection.removeObject(this);
        this._reflection = reflection;
        if (respawn) {
            this.spawnMe();
        }
        return true;
    }

    public boolean setReflection(int reflectionId) {
        Reflection r = ReflectionManager.getInstance().get(reflectionId);
        if (r == null) {
            Log.debug("Trying to set unavailable reflection: " + reflectionId + " for object: " + this + "!", new Throwable().fillInStackTrace());
            return false;
        }
        return this.setReflection(r);
    }

    public final int hashCode() {
        return this.objectId;
    }

    public final int getObjectId() {
        return this.objectId;
    }

    @Override
    public int getX() {
        return this._x;
    }

    @Override
    public int getY() {
        return this._y;
    }

    @Override
    public int getZ() {
        return this._z;
    }

    public Location getLoc() {
        return new Location(this._x, this._y, this._z, this.getHeading());
    }

    public int getGeoZ(int x, int y, int z) {
        return GeoEngine.correctGeoZ(x, y, z, this.getGeoIndex());
    }

    public final int getGeoZ(ILocation loc) {
        return this.getGeoZ(loc.getX(), loc.getY(), loc.getZ());
    }

    public boolean setLoc(ILocation loc) {
        return this.setXYZ(loc.getX(), loc.getY(), loc.getZ());
    }

    public boolean setXYZ(int x, int y, int z) {
        x = World.validCoordX(x);
        y = World.validCoordY(y);
        z = World.validCoordZ(z);
        z = this.getGeoZ(x, y, z);
        if (!this.isBoat()) {
            if (this.isFlying()) {
                z += 32;
            } else if (this.isInWater()) {
                z += 16;
            }
        }
        if (this._x == x && this._y == y && this._z == z) {
            return false;
        }
        this._x = x;
        this._y = y;
        this._z = z;
        World.addVisibleObject(this, null);
        this.refreshGeoControl();
        return true;
    }

    public boolean setZ(int z, boolean checkGeoZ) {
        z = World.validCoordZ(z);
        if (checkGeoZ) {
            z = this.getGeoZ(this.getX(), this.getY(), z);
            if (!this.isBoat()) {
                if (this.isFlying()) {
                    z += 32;
                } else if (this.isInWater()) {
                    z += 16;
                }
            }
        }
        if (this._z == z) {
            return false;
        }
        this._z = z;
        World.addVisibleObject(this, null);
        this.refreshGeoControl();
        return true;
    }

    public final boolean isVisible() {
        return this._state.get() == 1;
    }

    public boolean isInvisible(GameObject observer) {
        return false;
    }

    public void spawnMe(Location loc) {
        this.spawnMe0(loc, null);
    }

    protected void spawnMe0(Location loc, Creature dropper) {
        this._x = loc.x;
        this._y = loc.y;
        this._z = this.getGeoZ(loc);
        this.spawn0(dropper);
    }

    public final void spawnMe() {
        this.spawn0(null);
    }

    protected void spawn0(Creature dropper) {
        if (this._reflection.isCollapseStarted()) {
            return;
        }
        if (!this._state.compareAndSet(0, 1)) {
            return;
        }
        World.addVisibleObject(this, dropper);
        this.getReflection().addObject(this);
        this.onSpawn();
    }

    public void toggleVisible() {
        if (this.isVisible()) {
            this.decayMe();
        } else {
            this.spawnMe();
        }
    }

    protected void onSpawn() {
        this.activateGeoControl();
    }

    public final void decayMe() {
        if (!this._state.compareAndSet(1, 0)) {
            return;
        }
        World.removeVisibleObject(this);
        this.onDespawn();
    }

    protected void onDespawn() {
        this.deactivateGeoControl();
    }

    public final void deleteMe() {
        this.decayMe();
        if (!this._state.compareAndSet(0, -1)) {
            return;
        }
        this.onDelete();
    }

    public final boolean isDeleted() {
        return this._state.get() == -1;
    }

    protected void onDelete() {
        this.getReflection().removeObject(this);
        this.clearRef();
    }

    public void onAction(Player player, boolean shift) {
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, GameObject.class, this, true)) {
            return;
        }
        player.sendActionFailed();
    }

    public boolean isAttackable(Creature attacker) {
        return false;
    }

    public String getL2ClassShortName() {
        return this.getClass().getSimpleName();
    }

    public final boolean isInRange(GameObject obj, int range) {
        if (obj == null) {
            return false;
        }
        if (obj.getReflection() != this.getReflection()) {
            return false;
        }
        long dx = Math.abs(obj.getX() - this.getX());
        if (dx > (long)range) {
            return false;
        }
        long dy = Math.abs(obj.getY() - this.getY());
        if (dy > (long)range) {
            return false;
        }
        long dz = Math.abs(obj.getZ() - this.getZ());
        return dz <= 1500L && dx * dx + dy * dy <= (long)range * (long)range;
    }

    public final boolean isInRangeZ(GameObject obj, int range) {
        if (obj == null) {
            return false;
        }
        if (obj.getReflection() != this.getReflection()) {
            return false;
        }
        long dx = Math.abs(obj.getX() - this.getX());
        if (dx > (long)range) {
            return false;
        }
        long dy = Math.abs(obj.getY() - this.getY());
        if (dy > (long)range) {
            return false;
        }
        long dz = Math.abs(obj.getZ() - this.getZ());
        return dz <= (long)range && dx * dx + dy * dy + dz * dz <= (long)range * (long)range;
    }

    public final int getRealDistance(GameObject obj) {
        return this.getRealDistance3D(obj, true);
    }

    public final int getRealDistance3D(GameObject obj) {
        return this.getRealDistance3D(obj, false);
    }

    public final int getRealDistance3D(GameObject obj, boolean ignoreZ) {
        int distance;
        int n = distance = ignoreZ ? this.getDistance(obj) : this.getDistance3D(obj);
        if (this.isCreature()) {
            distance = (int)((double)distance - ((Creature)this).getCurrentCollisionRadius());
        }
        if (obj.isCreature()) {
            distance = (int)((double)distance - ((Creature)obj).getCurrentCollisionRadius());
        }
        return distance > 0 ? distance : 0;
    }

    public Player getPlayer() {
        return null;
    }

    @Override
    public int getHeading() {
        return 0;
    }

    public int getMoveSpeed() {
        return 0;
    }

    public WorldRegion getCurrentRegion() {
        return this._currentRegion;
    }

    public void setCurrentRegion(WorldRegion region) {
        this._currentRegion = region;
    }

    public boolean isObservePoint() {
        return false;
    }

    public boolean isInBoat() {
        return false;
    }

    public boolean isInShuttle() {
        return false;
    }

    public boolean isFlying() {
        return false;
    }

    public boolean isInWater() {
        return false;
    }

    public double getCollisionRadius() {
        _log.warn("getCollisionRadius called directly from GameObject");
        Thread.dumpStack();
        return 0.0;
    }

    public double getCollisionHeight() {
        _log.warn("getCollisionHeight called directly from GameObject");
        Thread.dumpStack();
        return 0.0;
    }

    public double getCurrentCollisionRadius() {
        return this.getCollisionRadius();
    }

    public double getCurrentCollisionHeight() {
        return this.getCollisionHeight();
    }

    public boolean isCreature() {
        return false;
    }

    public boolean isPlayable() {
        return false;
    }

    public boolean isPlayer() {
        return false;
    }

    public boolean isFakePlayer() {
        return false;
    }

    public boolean isPet() {
        return false;
    }

    public boolean isSummon() {
        return false;
    }

    public boolean isServitor() {
        return false;
    }

    public boolean isNpc() {
        return false;
    }

    public boolean isMonster() {
        return false;
    }

    public boolean isItem() {
        return false;
    }

    public boolean isRaid() {
        return false;
    }

    public boolean isReflectionBoss() {
        return false;
    }

    public boolean isArenaRaid() {
        return false;
    }

    public boolean isBoss() {
        return false;
    }

    public boolean isTrap() {
        return false;
    }

    public boolean isDoor() {
        return false;
    }

    public boolean isArtefact() {
        return false;
    }

    public boolean isSiegeGuard() {
        return false;
    }

    public boolean isBoat() {
        return false;
    }

    public boolean isVehicle() {
        return false;
    }

    public boolean isShuttle() {
        return false;
    }

    public boolean isMinion() {
        return false;
    }

    public String getName() {
        return this.getClass().getSimpleName() + ":" + this.objectId;
    }

    public String dump() {
        return this.dump(true);
    }

    public String dump(boolean simpleTypes) {
        return Util.dumpObject(this, simpleTypes, true, true);
    }

    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        return Collections.emptyList();
    }

    public List<L2GameServerPacket> deletePacketList(Player forPlayer) {
        return Collections.singletonList(new DeleteObjectPacket(this));
    }

    @Override
    public void addEvent(Event event) {
        super.addEvent(event);
        event.onAddEvent(this);
    }

    @Override
    public void removeEvent(Event event) {
        super.removeEvent(event);
        event.onRemoveEvent(this);
    }

    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (obj.getClass() != this.getClass()) {
            return false;
        }
        return ((GameObject)obj).getObjectId() == this.getObjectId();
    }

    public boolean isTargetable(Creature creature) {
        return true;
    }

    public boolean isDefender() {
        return false;
    }

    public boolean isStaticObject() {
        return false;
    }

    public boolean isFence() {
        return false;
    }

    protected Shape makeGeoShape() {
        return null;
    }

    @Override
    public Shape getGeoShape() {
        return this._geoShape;
    }

    public void setGeoShape(Shape shape) {
        this._geoShape = shape;
    }

    @Override
    public TIntObjectMap<ByteObjectPair<GeoEngine.CeilGeoControlType>> getGeoAround() {
        return this._geoAround;
    }

    @Override
    public void setGeoAround(TIntObjectMap<ByteObjectPair<GeoEngine.CeilGeoControlType>> value) {
        this._geoAround = value;
    }

    protected boolean isGeoControlEnabled() {
        return false;
    }

    protected final void refreshGeoControl() {
        this._geoLock.lock();
        try {
            this.deactivateGeoControl();
            this.setGeoAround(null);
            this.setGeoShape(null);
            this.activateGeoControl();
        }
        finally {
            this._geoLock.unlock();
        }
    }

    public final boolean isGeoControlActivated() {
        return this._geoControlIndex > 0;
    }

    public final boolean activateGeoControl() {
        if (!Config.ALLOW_GEODATA) {
            return true;
        }
        this._geoLock.lock();
        try {
            int geoIndex;
            if (!this.isGeoControlEnabled()) {
                boolean bl = false;
                return bl;
            }
            if (this.isGeoControlActivated()) {
                boolean bl = false;
                return bl;
            }
            if (!this.isVisible()) {
                boolean bl = false;
                return bl;
            }
            if (this.getGeoShape() == null) {
                Shape shape = this.makeGeoShape();
                if (shape == null) {
                    boolean bl = false;
                    return bl;
                }
                this.setGeoShape(shape);
            }
            if (!GeoEngine.applyGeoControl(this, geoIndex = this.getGeoIndex())) {
                boolean bl = false;
                return bl;
            }
            this._geoControlIndex = geoIndex;
            boolean bl = true;
            return bl;
        }
        finally {
            this._geoLock.unlock();
        }
    }

    public final boolean deactivateGeoControl() {
        if (!Config.ALLOW_GEODATA) {
            return true;
        }
        this._geoLock.lock();
        try {
            if (!this.isGeoControlActivated()) {
                boolean bl = false;
                return bl;
            }
            if (!GeoEngine.returnGeoControl(this)) {
                boolean bl = false;
                return bl;
            }
            this._geoControlIndex = 0;
            boolean bl = true;
            return bl;
        }
        finally {
            this._geoLock.unlock();
        }
    }

    @Override
    public final int getGeoControlIndex() {
        return this._geoControlIndex;
    }

    @Override
    public boolean isHollowGeo() {
        return true;
    }
}

