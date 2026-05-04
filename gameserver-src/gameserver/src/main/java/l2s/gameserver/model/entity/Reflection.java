/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity;

import gnu.trove.set.hash.TIntHashSet;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.SpawnHolder;
import l2s.gameserver.database.mysql;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.LocationsList;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.instancemanager.EventTriggersManager;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.instancemanager.SpawnManager;
import l2s.gameserver.listener.actor.door.impl.MasterOnOpenCloseListenerImpl;
import l2s.gameserver.listener.reflection.OnReflectionCollapseListener;
import l2s.gameserver.listener.zone.impl.EpicZoneListener;
import l2s.gameserver.listener.zone.impl.FishingZoneListener;
import l2s.gameserver.listener.zone.impl.NoLandingZoneListener;
import l2s.gameserver.listener.zone.impl.PresentSceneMovieZoneListener;
import l2s.gameserver.listener.zone.impl.ResidenceEnterLeaveListenerImpl;
import l2s.gameserver.listener.zone.impl.SiegeZoneListener;
import l2s.gameserver.listener.zone.impl.TeleportingZoneListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.HardSpawner;
import l2s.gameserver.model.ObservePoint;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.EventTriggerPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.DoorTemplate;
import l2s.gameserver.templates.InstantZone;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.ZoneTemplate;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.templates.spawn.SpawnTemplate;
import l2s.gameserver.utils.NpcUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.napile.primitive.Containers;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Reflection {
    private static final Logger _log = LoggerFactory.getLogger(Reflection.class);
    private static final AtomicInteger _nextId = new AtomicInteger();
    private static final AtomicBoolean _closed = new AtomicBoolean(false);
    private final int _id;
    private String _name = "";
    private InstantZone _instance;
    private final int _geoIndex;
    private Location _resetLoc;
    private Location _returnLoc;
    private Location _teleportLoc;
    protected Set<Spawner> _spawns = new HashSet<Spawner>();
    protected Set<GameObject> _objects = new HashSet<GameObject>();
    protected IntObjectMap<DoorInstance> _doors = Containers.emptyIntObjectMap();
    protected Map<String, Zone> _zones = Collections.emptyMap();
    protected Map<String, List<Spawner>> _spawners = Collections.emptyMap();
    protected TIntHashSet _visitors = new TIntHashSet();
    protected final Lock lock = new ReentrantLock();
    protected int _playerCount;
    protected Party _party;
    private int _collapseIfEmptyTime;
    private boolean _isCollapseStarted;
    private ScheduledFuture<?> _collapseTask;
    private ScheduledFuture<?> _collapse1minTask;
    private ScheduledFuture<?> _hiddencollapseTask;
    private final ReflectionListenerList listeners = new ReflectionListenerList();
    private StatsSet _variables = StatsSet.EMPTY;

    public Reflection() {
        this(_nextId.incrementAndGet());
    }

    protected Reflection(int id) {
        this._id = id;
        this._geoIndex = GeoEngine.createGeoIndex();
    }

    public int getId() {
        return this._id;
    }

    public int getInstancedZoneId() {
        return this._instance == null ? -1 : this._instance.getId();
    }

    public void setParty(Party party) {
        this._party = party;
    }

    public Party getParty() {
        return this._party;
    }

    public void setCollapseIfEmptyTime(int value) {
        this._collapseIfEmptyTime = value;
    }

    public String getName() {
        return this._name;
    }

    protected void setName(String name) {
        this._name = name;
    }

    public InstantZone getInstancedZone() {
        return this._instance;
    }

    protected void setInstancedZone(InstantZone iz) {
        this._instance = iz;
    }

    public int getGeoIndex() {
        return this._geoIndex;
    }

    public void setCoreLoc(Location l) {
        this._resetLoc = l;
    }

    public Location getCoreLoc() {
        return this._resetLoc;
    }

    public void setReturnLoc(Location l) {
        this._returnLoc = l;
    }

    public Location getReturnLoc() {
        return this._returnLoc;
    }

    public void setTeleportLoc(Location l) {
        this._teleportLoc = l;
    }

    public Location getTeleportLoc() {
        return this._teleportLoc;
    }

    public Collection<Spawner> getSpawns() {
        return this._spawns;
    }

    public Collection<DoorInstance> getDoors() {
        return this._doors.valueCollection();
    }

    public DoorInstance getDoor(int id) {
        return (DoorInstance)this._doors.get(id);
    }

    public void addZone(Zone zone) {
        if (zone.getReflection() == this) {
            if (this._zones.isEmpty()) {
                this._zones = new HashMap<String, Zone>();
            }
            this._zones.put(zone.getName(), zone);
        }
    }

    public Zone getZone(String name) {
        return this._zones.get(name);
    }

    public void startCollapseTimer(int minutes, boolean message) {
        if (this.isDefault()) {
            new Exception("Basic reflection " + this._id + " could not be collapsed!").printStackTrace();
            return;
        }
        this.lock.lock();
        try {
            if (this._collapseTask != null) {
                this._collapseTask.cancel(false);
                this._collapseTask = null;
            }
            if (this._collapse1minTask != null) {
                this._collapse1minTask.cancel(false);
                this._collapse1minTask = null;
            }
            if (message) {
                this.broadcastExpireMsg(minutes);
            }
            if (minutes > 0) {
                this._collapseTask = ThreadPoolManager.getInstance().schedule(() -> this.collapse(), TimeUnit.MINUTES.toMillis(minutes));
                if (minutes > 1) {
                    this._collapse1minTask = ThreadPoolManager.getInstance().schedule(() -> {
                        if (this._isCollapseStarted) {
                            return;
                        }
                        this.broadcastExpireMsg(1);
                    }, TimeUnit.MINUTES.toMillis(minutes - 1));
                }
            } else {
                this._collapseTask = ThreadPoolManager.getInstance().schedule(() -> this.collapse(), 1000L);
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public void stopCollapseTimer() {
        this.lock.lock();
        try {
            if (this._collapseTask != null) {
                this._collapseTask.cancel(false);
                this._collapseTask = null;
            }
            if (this._collapse1minTask != null) {
                this._collapse1minTask.cancel(false);
                this._collapse1minTask = null;
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public long getDelayToCollapse() {
        if (this._collapseTask != null) {
            return this._collapseTask.getDelay(TimeUnit.MILLISECONDS);
        }
        return -1L;
    }

    
    public void collapse() {
        if (this._id <= 0) {
            new Exception("Basic reflection " + this._id + " could not be collapsed!").printStackTrace();
            return;
        }
        this.lock.lock();
        try {
            if (this._isCollapseStarted) {
                return;
            }
            this._isCollapseStarted = true;
            this.listeners.onCollapse();
            try {
                this.stopCollapseTimer();
                if (this._hiddencollapseTask != null) {
                    this._hiddencollapseTask.cancel(false);
                    this._hiddencollapseTask = null;
                }
                for (Spawner s : this._spawns) {
                    s.deleteAll();
                }
                for (String group : this._spawners.keySet()) {
                    this.despawnByGroup(group);
                }
                for (DoorInstance d : this._doors.valueCollection()) {
                    d.deleteMe();
                }
                this._doors.clear();
                for (Zone zone : this._zones.values()) {
                    zone.setActive(false);
                }
                this._zones.clear();
                EventTriggersManager.getInstance().removeTriggers(this);
                ArrayList<Player> teleport = new ArrayList<Player>();
                ArrayList<ObservePoint> observers = new ArrayList<ObservePoint>();
                ArrayList<GameObject> delete = new ArrayList<GameObject>();
                for (GameObject gameObject : this._objects) {
                    if (gameObject.isPlayer()) {
                        teleport.add((Player)gameObject);
                        continue;
                    }
                    if (gameObject.isObservePoint()) {
                        observers.add((ObservePoint)gameObject);
                        continue;
                    }
                    if (gameObject.isPlayable()) continue;
                    delete.add(gameObject);
                }
                for (Player player : teleport) {
                    if (player.getParty() != null && this.equals(player.getParty().getReflection())) {
                        player.getParty().setReflection(null);
                    }
                    if (this.equals(player.getReflection())) {
                        if (this.getReturnLoc() != null) {
                            player.teleToLocation((ILocation)this.getReturnLoc(), ReflectionManager.MAIN);
                        } else {
                            player.setReflection(ReflectionManager.MAIN);
                        }
                    }
                    this.onPlayerExit(player);
                }
                for (Player player : GameObjectsStorage.getPlayers(true, true)) {
                    if (player.getActiveReflection() != this) continue;
                    player.setActiveReflection(null);
                }
                for (ObservePoint observePoint : observers) {
                    Player observer = observePoint.getPlayer();
                    if (observer == null) continue;
                    observer.leaveObserverMode();
                }
                if (this._party != null) {
                    this._party.setReflection(null);
                    this._party = null;
                }
                for (GameObject gameObject : delete) {
                    gameObject.deleteMe();
                }
                this._spawns.clear();
                this._objects.clear();
                this._visitors.clear();
                this._doors.clear();
                this._playerCount = 0;
                this.onCollapse();
            }
            finally {
                ReflectionManager.getInstance().remove(this);
                GeoEngine.deleteGeoIndex(this.getGeoIndex());
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    protected void onCollapse() {
    }

    public void addObject(GameObject o) {
        if (this._isCollapseStarted) {
            return;
        }
        this.lock.lock();
        try {
            if (!this._objects.add(o)) {
                return;
            }
            this.onAddObject(o);
            if (o.isPlayer()) {
                ++this._playerCount;
                this._visitors.add(o.getObjectId());
                Player player = o.getPlayer();
                if (!this.isDefault()) {
                    player.setActiveReflection(this);
                }
                this.onPlayerEnter(player);
            }
            if (this._hiddencollapseTask != null) {
                this._hiddencollapseTask.cancel(false);
                this._hiddencollapseTask = null;
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public void removeObject(GameObject o) {
        if (this._isCollapseStarted) {
            return;
        }
        this.lock.lock();
        try {
            if (!this._objects.remove(o)) {
                return;
            }
            this.onRemoveObject(o);
            if (o.isPlayer()) {
                --this._playerCount;
                this.onPlayerExit(o.getPlayer());
                if (this._playerCount <= 0 && !this.isDefault() && this._hiddencollapseTask == null && this._collapseIfEmptyTime >= 0) {
                    if (this._collapseIfEmptyTime == 0) {
                        this.collapse();
                    } else {
                        this._hiddencollapseTask = ThreadPoolManager.getInstance().schedule(() -> this.collapse(), (long)(this._collapseIfEmptyTime * 60) * 1000L);
                    }
                }
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public void onAddObject(GameObject object) {
    }

    public void onRemoveObject(GameObject object) {
    }

    public void onPlayerEnter(Player player) {
        player.getInventory().validateItems();
        for (int triggerId : EventTriggersManager.getInstance().getTriggers(this, false)) {
            player.sendPacket((IBroadcastPacket)new EventTriggerPacket(triggerId, true));
        }
    }

    public void onPlayerExit(Player player) {
        player.getInventory().validateItems();
        for (int triggerId : EventTriggersManager.getInstance().getTriggers(this, true)) {
            player.sendPacket((IBroadcastPacket)new EventTriggerPacket(triggerId, false));
        }
        if (player.getActiveSubClass() != null) {
            Iterator<Servitor> object = player.getServitors().iterator();
            while (object.hasNext()) {
                Servitor servitor = object.next();
                if (servitor == null || servitor.getNpcId() != 14916 && servitor.getNpcId() != 14917) continue;
                servitor.unSummon(false);
            }
        }
    }

    
    public List<Player> getPlayers() {
        ArrayList<Player> result = new ArrayList<Player>();
        this.lock.lock();
        try {
            for (GameObject o : this._objects) {
                if (!o.isPlayer()) continue;
                result.add((Player)o);
            }
        }
        finally {
            this.lock.unlock();
        }
        return result;
    }

    
    public List<Creature> getPlayersAndObservers() {
        ArrayList<Creature> result = new ArrayList<Creature>();
        this.lock.lock();
        try {
            for (GameObject o : this._objects) {
                if (!o.isPlayer() && !o.isObservePoint()) continue;
                result.add((Creature)o);
            }
        }
        finally {
            this.lock.unlock();
        }
        return result;
    }

    
    public List<Creature> getObservers() {
        ArrayList<Creature> result = new ArrayList<Creature>();
        this.lock.lock();
        try {
            for (GameObject o : this._objects) {
                if (!o.isObservePoint()) continue;
                result.add((Creature)o);
            }
        }
        finally {
            this.lock.unlock();
        }
        return result;
    }

    
    public List<NpcInstance> getNpcs() {
        ArrayList<NpcInstance> result = new ArrayList<NpcInstance>();
        this.lock.lock();
        try {
            for (GameObject o : this._objects) {
                if (!o.isNpc()) continue;
                result.add((NpcInstance)o);
            }
        }
        finally {
            this.lock.unlock();
        }
        return result;
    }

    public List<NpcInstance> getNpcs(boolean onlyAlive, int ... npcIds) {
        return this.getNpcs(onlyAlive, onlyAlive, npcIds);
    }

    
    public List<NpcInstance> getNpcs(boolean onlyAlive, boolean onlySpawned, int ... npcIds) {
        ArrayList<NpcInstance> result = new ArrayList<NpcInstance>();
        this.lock.lock();
        try {
            for (GameObject o : this._objects) {
                if (!o.isNpc()) continue;
                NpcInstance npc = (NpcInstance)o;
                if (npcIds.length != 0 && !ArrayUtils.contains((int[])npcIds, (int)npc.getNpcId()) || onlyAlive && npc.isDead() || onlySpawned && !npc.isVisible()) continue;
                result.add(npc);
            }
        }
        finally {
            this.lock.unlock();
        }
        return result;
    }

    public boolean canChampions() {
        return this._id <= 0;
    }

    public boolean isAutolootForced() {
        return false;
    }

    public boolean isCollapseStarted() {
        return this._isCollapseStarted;
    }

    public void addSpawn(Spawner spawn) {
        if (spawn != null) {
            this._spawns.add(spawn);
        }
    }

    public void fillSpawns(List<InstantZone.SpawnInfo> si) {
        if (si == null) {
            return;
        }
        block5: for (InstantZone.SpawnInfo s : si) {
            switch (s.getSpawnType()) {
                case 0: {
                    for (Location loc : s.getCoords()) {
                        this.addSpawn(NpcUtils.spawnSimple(s.getNpcId(), loc, this, 1, s.getRespawnDelay(), s.getRespawnRnd(), null));
                    }
                    continue block5;
                }
                case 1: {
                    this.addSpawn(NpcUtils.spawnSimple(s.getNpcId(), new LocationsList(s.getCoords()), this, 1, s.getRespawnDelay(), s.getRespawnRnd(), null));
                    break;
                }
                case 2: {
                    this.addSpawn(NpcUtils.spawnSimple(s.getNpcId(), s.getLoc(), this, s.getCount(), s.getRespawnDelay(), s.getRespawnRnd(), null));
                }
            }
        }
    }

    public void init(IntObjectMap<DoorTemplate> doors, Map<String, ZoneTemplate> zones) {
        if (!doors.isEmpty()) {
            this._doors = new HashIntObjectMap(doors.size());
        }
        for (DoorTemplate doorTemplate : doors.valueCollection()) {
            DoorInstance door = new DoorInstance(IdFactory.getInstance().getNextId(), doorTemplate);
            door.setReflection(this);
            door.getFlags().getInvulnerable().start();
            door.spawnMe(doorTemplate.getLoc());
            if (doorTemplate.isOpened()) {
                door.openMe();
            }
            this._doors.put(doorTemplate.getId(), door);
        }
        this.initDoors();
        if (!zones.isEmpty()) {
            this._zones = new HashMap<String, Zone>(zones.size());
        }
        for (ZoneTemplate zoneTemplate : zones.values()) {
            Zone zone = new Zone(zoneTemplate);
            zone.setReflection(this);
            switch (zone.getType()) {
                case no_landing: {
                    zone.addListener(NoLandingZoneListener.STATIC);
                    break;
                }
                case epic: {
                    zone.addListener(EpicZoneListener.STATIC);
                    break;
                }
                case RESIDENCE: {
                    zone.addListener(ResidenceEnterLeaveListenerImpl.STATIC);
                    break;
                }
                case FISHING: {
                    zone.addListener(FishingZoneListener.STATIC);
                    break;
                }
                case SIEGE: {
                    zone.addListener(NoLandingZoneListener.STATIC);
                    zone.addListener(SiegeZoneListener.STATIC);
                    break;
                }
                case TELEPORT: {
                    zone.addListener(TeleportingZoneListener.STATIC);
                }
            }
            if (zoneTemplate.getPresentSceneMovie() != null) {
                zone.addListener(new PresentSceneMovieZoneListener(zoneTemplate.getPresentSceneMovie()));
            }
            if (zoneTemplate.isEnabled()) {
                zone.setActive(true);
            }
            this._zones.put(zoneTemplate.getName(), zone);
        }
        this.onCreate();
    }

    private void init0(IntObjectMap<InstantZone.DoorInfo> doors, Map<String, InstantZone.ZoneInfo> zones) {
        if (!doors.isEmpty()) {
            this._doors = new HashIntObjectMap(doors.size());
        }
        for (InstantZone.DoorInfo info : doors.valueCollection()) {
            DoorInstance door = new DoorInstance(IdFactory.getInstance().getNextId(), info.getTemplate());
            door.setReflection(this);
            if (info.isInvulnerable() && !door.isInvulnerable()) {
                door.getFlags().getInvulnerable().start();
            } else if (!info.isInvulnerable() && door.isInvulnerable()) {
                door.getFlags().getInvulnerable().stop();
            }
            door.spawnMe(info.getTemplate().getLoc());
            if (info.isOpened()) {
                door.openMe();
            }
            this._doors.put(info.getTemplate().getId(), door);
        }
        this.initDoors();
        if (!zones.isEmpty()) {
            this._zones = new HashMap<String, Zone>(zones.size());
        }
        for (InstantZone.ZoneInfo t : zones.values()) {
            Zone zone = new Zone(t.getTemplate());
            zone.setReflection(this);
            switch (zone.getType()) {
                case no_landing: {
                    zone.addListener(NoLandingZoneListener.STATIC);
                    break;
                }
                case epic: {
                    zone.addListener(EpicZoneListener.STATIC);
                    break;
                }
                case RESIDENCE: {
                    zone.addListener(ResidenceEnterLeaveListenerImpl.STATIC);
                    break;
                }
                case FISHING: {
                    zone.addListener(FishingZoneListener.STATIC);
                    break;
                }
                case SIEGE: {
                    zone.addListener(NoLandingZoneListener.STATIC);
                    zone.addListener(SiegeZoneListener.STATIC);
                    break;
                }
                case TELEPORT: {
                    zone.addListener(TeleportingZoneListener.STATIC);
                }
            }
            if (t.getTemplate().getPresentSceneMovie() != null) {
                zone.addListener(new PresentSceneMovieZoneListener(t.getTemplate().getPresentSceneMovie()));
            }
            if (t.isActive()) {
                zone.setActive(true);
            }
            this._zones.put(t.getTemplate().getName(), zone);
        }
    }

    private void initDoors() {
        for (DoorInstance door : this._doors.valueCollection()) {
            if (door.getTemplate().getMasterDoor() <= 0) continue;
            DoorInstance masterDoor = this.getDoor(door.getTemplate().getMasterDoor());
            masterDoor.addListener(new MasterOnOpenCloseListenerImpl(door));
        }
    }

    public void openDoor(int doorId) {
        DoorInstance door = (DoorInstance)this._doors.get(doorId);
        if (door != null) {
            door.openMe();
        }
    }

    public void closeDoor(int doorId) {
        DoorInstance door = (DoorInstance)this._doors.get(doorId);
        if (door != null) {
            door.closeMe();
        }
    }

    public void clearReflection(int timeInMinutes, boolean message) {
        if (this.isDefault()) {
            return;
        }
        for (NpcInstance n : this.getNpcs()) {
            n.deleteMe();
        }
        this.startCollapseTimer(timeInMinutes, message);
    }

    public void broadcastExpireMsg(int minutesToExpire) {
        Object msg = this.isDungeon() ? new SystemMessagePacket(SystemMsg.THIS_DUNGEON_WILL_EXPIRE_IN_S1_MINUTES_YOU_WILL_BE_FORCED_OUT_OF_THE_DUNGEON_WHEN_THE_TIME_EXPIRES).addInteger(minutesToExpire) : new SystemMessagePacket(SystemMsg.THIS_INSTANT_ZONE_WILL_BE_TERMINATED_IN_S1_MINUTES_YOU_WILL_BE_FORCED_OUT_OF_THE_DUNGEON_WHEN_THE_TIME_EXPIRES).addInteger(minutesToExpire);
        for (Player player : this.getPlayers()) {
            player.sendPacket((IBroadcastPacket)msg);
        }
    }

    public NpcInstance addSpawnWithoutRespawn(int npcId, Location loc, int randomOffset) {
        if (this._isCollapseStarted) {
            return null;
        }
        Location newLoc = randomOffset > 0 ? Location.findPointToStay(loc, 0, randomOffset, this.getGeoIndex()).setH(loc.h) : loc;
        return NpcUtils.spawnSingle(npcId, (SpawnRange)newLoc, this);
    }

    public NpcInstance addSpawnWithRespawn(int npcId, Location loc, int randomOffset, int respawnDelay) {
        if (this._isCollapseStarted) {
            return null;
        }
        Spawner sp = NpcUtils.spawnSimple(npcId, randomOffset > 0 ? Location.findPointToStay(loc, 0, randomOffset, this.getGeoIndex()) : loc, this, 1, respawnDelay, 0);
        return sp.getLastSpawn();
    }

    public boolean isMain() {
        return this.getId() == 0;
    }

    public boolean isDefault() {
        return this.getId() <= 0;
    }

    public boolean isVisitor(Player player) {
        return this._visitors.contains(player.getObjectId());
    }

    public int[] getVisitors() {
        return this._visitors.toArray();
    }

    public void removeVisitors(Player player) {
        this._visitors.remove(player.getObjectId());
    }

    
    public void setReenterTime(long time, boolean notify) {
        int[] players = null;
        this.lock.lock();
        try {
            players = this._visitors.toArray();
        }
        finally {
            this.lock.unlock();
        }
        if (players != null) {
            for (int objectId : players) {
                try {
                    Player player = World.getPlayer(objectId);
                    if (player != null) {
                        player.setInstanceReuse(this.getInstancedZoneId(), time, notify);
                        continue;
                    }
                    mysql.set("REPLACE INTO character_instances (obj_id, id, reuse) VALUES (?,?,?)", objectId, this.getInstancedZoneId(), time);
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    protected void onCreate() {
        ReflectionManager.getInstance().add(this);
    }

    public static Reflection createReflection(int id) {
        if (id > 0) {
            throw new IllegalArgumentException("id should be <= 0");
        }
        return new Reflection(id);
    }

    public void init(InstantZone instantZone) {
        this.setName(instantZone.getName());
        this.setInstancedZone(instantZone);
        this.setTeleportLoc(instantZone.getTeleportCoord());
        if (instantZone.getReturnCoords() != null) {
            this.setReturnLoc(instantZone.getReturnCoords());
        }
        this.fillSpawns(instantZone.getSpawnsInfo());
        if (instantZone.getSpawns().size() > 0) {
            this._spawners = new HashMap<String, List<Spawner>>(instantZone.getSpawns().size());
            for (Map.Entry<String, InstantZone.SpawnInfo2> entry : instantZone.getSpawns().entrySet()) {
                ArrayList<HardSpawner> spawnList = new ArrayList<HardSpawner>(entry.getValue().getTemplates().size());
                this._spawners.put(entry.getKey(), (List<Spawner>)(List<?>)spawnList);
                for (SpawnTemplate template : entry.getValue().getTemplates()) {
                    HardSpawner spawner = new HardSpawner(template);
                    spawnList.add(spawner);
                    spawner.setAmount(template.getCount());
                    spawner.setRespawnDelay(template.getRespawn(), template.getRespawnRandom());
                    spawner.setRespawnPattern(template.getRespawnPattern());
                    spawner.setReflection(this);
                    spawner.setRespawnTime(0);
                }
                if (!entry.getValue().isSpawned()) continue;
                this.spawnByGroup(entry.getKey());
            }
        }
        this.init0(instantZone.getDoors(), instantZone.getZones());
        this.setCollapseIfEmptyTime(instantZone.getCollapseIfEmpty());
        if (instantZone.getTimelimit() > 0) {
            this.startCollapseTimer(instantZone.getTimelimit(), false);
        }
        this.onCreate();
    }

    public List<Spawner> spawnByGroup(String name) {
        if (this.isMain()) {
            return SpawnManager.getInstance().spawn(name, false);
        }
        List<Spawner> list = this._spawners.get(name);
        if (list == null) {
            if (this._spawners.isEmpty()) {
                this._spawners = new HashMap<String, List<Spawner>>(1);
            }
            List<SpawnTemplate> templates = SpawnHolder.getInstance().getSpawn(name);
            ArrayList<Spawner> spawnList = new ArrayList<Spawner>(templates.size());
            this._spawners.put(name, spawnList);
            for (SpawnTemplate template : templates) {
                HardSpawner spawner = new HardSpawner(template);
                spawnList.add(spawner);
                spawner.setAmount(template.getCount());
                spawner.setRespawnDelay(template.getRespawn(), template.getRespawnRandom());
                spawner.setRespawnPattern(template.getRespawnPattern());
                spawner.setReflection(this);
                spawner.setRespawnTime(0);
                spawner.init();
            }
            return spawnList;
        }
        for (Spawner s : list) {
            s.init();
        }
        return list;
    }

    public void despawnByGroup(String name) {
        if (this.isMain()) {
            SpawnManager.getInstance().despawn(name);
        } else {
            List<Spawner> list = this._spawners.get(name);
            if (list != null) {
                for (Spawner s : list) {
                    s.deleteAll();
                }
            }
        }
    }

    public void despawnAll() {
        if (this.isMain()) {
            SpawnManager.getInstance().despawnAll();
        } else {
            for (List<Spawner> list : this._spawners.values()) {
                for (Spawner s : list) {
                    s.deleteAll();
                }
            }
        }
    }

    public List<Spawner> getSpawners(String group) {
        if (this.isMain()) {
            return SpawnManager.getInstance().getSpawners(group);
        }
        List<Spawner> list = this._spawners.get(group);
        return list == null ? Collections.emptyList() : list;
    }

    public Collection<Zone> getZones() {
        return this._zones.values();
    }

    public <T extends Listener<Reflection>> boolean addListener(T listener) {
        return this.listeners.add(listener);
    }

    public <T extends Listener<Reflection>> boolean removeListener(T listener) {
        return this.listeners.remove(listener);
    }

    public void clearVisitors() {
        this._visitors.clear();
    }

    public void broadcastPacket(IBroadcastPacket ... packets) {
        for (Player player : this.getPlayers()) {
            if (player == null) continue;
            player.sendPacket(packets);
        }
    }

    public void broadcastPacket(List<IBroadcastPacket> packets) {
        for (Player player : this.getPlayers()) {
            if (player == null) continue;
            player.sendPacket(packets);
        }
    }

    public final StatsSet getVariables() {
        return this._variables;
    }

    public final void setVariable(String name, Object value) {
        if (this._variables == StatsSet.EMPTY) {
            this._variables = new StatsSet();
        }
        this._variables.set(name, value);
    }

    public boolean addEventTrigger(int triggerId) {
        return EventTriggersManager.getInstance().addTrigger(this, triggerId);
    }

    public boolean removeEventTrigger(int triggerId) {
        return EventTriggersManager.getInstance().removeTrigger(this, triggerId);
    }

    public boolean isClosed() {
        return _closed.get();
    }

    public boolean close() {
        return _closed.compareAndSet(false, true);
    }

    public boolean isDungeon() {
        return false;
    }

    public class ReflectionListenerList
    extends ListenerList<Reflection> {
        public void onCollapse() {
            if (!this.getListeners().isEmpty()) {
                for (Listener listener : this.getListeners()) {
                    ((OnReflectionCollapseListener)listener).onReflectionCollapse(Reflection.this);
                }
            }
        }
    }
}

