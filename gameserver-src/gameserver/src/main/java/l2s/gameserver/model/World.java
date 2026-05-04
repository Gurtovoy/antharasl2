/*
 * This file was originally decompiled from L2S rev.[31495].
 * Refactored: improved getRegion() double-checked locking pattern, removed CFR artifacts.
 */
package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import l2s.commons.collections.LazyArrayList;
import l2s.gameserver.Config;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.instancemanager.EventTriggersManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.WorldRegion;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.EventTriggerPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.MapUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class World {
    private static final Logger _log = LoggerFactory.getLogger(World.class);
    public static final int MAP_MIN_X = Config.GEO_X_FIRST - 20 << 15;
    public static final int MAP_MAX_X = (Config.GEO_X_LAST - 20 + 1 << 15) - 1;
    public static final int MAP_MIN_Y = Config.GEO_Y_FIRST - 18 << 15;
    public static final int MAP_MAX_Y = (Config.GEO_Y_LAST - 18 + 1 << 15) - 1;
    public static final int MAP_MIN_Z = Config.MAP_MIN_Z;
    public static final int MAP_MAX_Z = Config.MAP_MAX_Z;
    public static final int WORLD_SIZE_X = Config.GEO_X_LAST - Config.GEO_X_FIRST + 1;
    public static final int WORLD_SIZE_Y = Config.GEO_Y_LAST - Config.GEO_Y_FIRST + 1;
    public static final int SHIFT_BY = Config.SHIFT_BY;
    public static final int SHIFT_BY_Z = Config.SHIFT_BY_Z;
    public static final int OFFSET_X = Math.abs(MAP_MIN_X >> SHIFT_BY);
    public static final int OFFSET_Y = Math.abs(MAP_MIN_Y >> SHIFT_BY);
    public static final int OFFSET_Z = Math.abs(MAP_MIN_Z >> SHIFT_BY_Z);
    private static final int REGIONS_X = (MAP_MAX_X >> SHIFT_BY) + OFFSET_X;
    private static final int REGIONS_Y = (MAP_MAX_Y >> SHIFT_BY) + OFFSET_Y;
    private static final int REGIONS_Z = (MAP_MAX_Z >> SHIFT_BY_Z) + OFFSET_Z;
    private static volatile WorldRegion[][][] _worldRegions = new WorldRegion[REGIONS_X + 1][REGIONS_Y + 1][REGIONS_Z + 1];

    public static void init() {
        _log.info("World: Creating regions: [" + (REGIONS_X + 1) + "][" + (REGIONS_Y + 1) + "][" + (REGIONS_Z + 1) + "].");
    }

    private static WorldRegion[][][] getRegions() {
        return _worldRegions;
    }

    private static int validX(int x) {
        if (x < 0) {
            x = 0;
        } else if (x > REGIONS_X) {
            x = REGIONS_X;
        }
        return x;
    }

    private static int validY(int y) {
        if (y < 0) {
            y = 0;
        } else if (y > REGIONS_Y) {
            y = REGIONS_Y;
        }
        return y;
    }

    private static int validZ(int z) {
        if (z < 0) {
            z = 0;
        } else if (z > REGIONS_Z) {
            z = REGIONS_Z;
        }
        return z;
    }

    public static int validCoordX(int x) {
        if (x < MAP_MIN_X) {
            x = MAP_MIN_X + 1;
        } else if (x > MAP_MAX_X) {
            x = MAP_MAX_X - 1;
        }
        return x;
    }

    public static int validCoordY(int y) {
        if (y < MAP_MIN_Y) {
            y = MAP_MIN_Y + 1;
        } else if (y > MAP_MAX_Y) {
            y = MAP_MAX_Y - 1;
        }
        return y;
    }

    public static int validCoordZ(int z) {
        if (z < MAP_MIN_Z) {
            z = MAP_MIN_Z + 1;
        } else if (z > MAP_MAX_Z) {
            z = MAP_MAX_Z - 1;
        }
        return z;
    }

    private static int regionX(int x) {
        return (x >> SHIFT_BY) + OFFSET_X;
    }

    private static int regionY(int y) {
        return (y >> SHIFT_BY) + OFFSET_Y;
    }

    private static int regionZ(int z) {
        return (z >> SHIFT_BY_Z) + OFFSET_Z;
    }

    private static int regionToCordX(int x) {
        return x - OFFSET_X << SHIFT_BY;
    }

    private static int regionToCordY(int y) {
        return y - OFFSET_Y << SHIFT_BY;
    }

    private static int regionToCordZ(int z) {
        return z - OFFSET_Z << SHIFT_BY_Z;
    }

    static boolean isNeighbour(int x1, int y1, int z1, int x2, int y2, int z2) {
        return x1 <= x2 + 1 && x1 >= x2 - 1 && y1 <= y2 + 1 && y1 >= y2 - 1 && z1 <= z2 + 1 && z1 >= z2 - 1;
    }

    public static WorldRegion getRegion(Location loc) {
        return World.getRegion(World.validX(World.regionX(loc.x)), World.validY(World.regionY(loc.y)), World.validZ(World.regionZ(loc.z)));
    }

    public static WorldRegion getRegion(GameObject obj) {
        return World.getRegion(World.validX(World.regionX(obj.getX())), World.validY(World.regionY(obj.getY())), World.validZ(World.regionZ(obj.getZ())));
    }

    /**
     * Returns the WorldRegion at the given region coordinates.
     * Uses double-checked locking: fast unsynchronized read path,
     * synchronized creation path to avoid duplicate region construction.
     */
    private static WorldRegion getRegion(int x, int y, int z)
    {
        WorldRegion[][][] regions = getRegions();
        WorldRegion region = regions[x][y][z];
        if (region != null)
        {
            return region;
        }
        synchronized (regions)
        {
            region = regions[x][y][z];
            if (region != null)
            {
                return region;
            }
            region = new WorldRegion(x, y, z);
            regions[x][y][z] = region;
            return region;
        }
    }

    public static Player getPlayer(String name) {
        return GameObjectsStorage.getPlayer(name);
    }

    public static Player getPlayer(int objId) {
        return GameObjectsStorage.getPlayer(objId);
    }

    public static void addVisibleObject(GameObject object, Creature dropper) {
        int z;
        int y;
        int x;
        if (object == null || !object.isVisible()) {
            return;
        }
        WorldRegion region = World.getRegion(object);
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == region) {
            return;
        }
        if (currentRegion == null) {
            object.setCurrentRegion(region);
            region.addObject(object);
            for (x = World.validX(region.getX() - 1); x <= World.validX(region.getX() + 1); ++x) {
                for (y = World.validY(region.getY() - 1); y <= World.validY(region.getY() + 1); ++y) {
                    for (z = World.validZ(region.getZ() - 1); z <= World.validZ(region.getZ() + 1); ++z) {
                        World.getRegion(x, y, z).addToObservers(object, dropper);
                    }
                }
            }
        } else {
            currentRegion.removeObject(object);
            object.setCurrentRegion(region);
            region.addObject(object);
            for (x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
                for (y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                    for (z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                        if (World.isNeighbour(region.getX(), region.getY(), region.getZ(), x, y, z)) continue;
                        World.getRegion(x, y, z).removeFromObservers(object);
                    }
                }
            }
            for (x = World.validX(region.getX() - 1); x <= World.validX(region.getX() + 1); ++x) {
                for (y = World.validY(region.getY() - 1); y <= World.validY(region.getY() + 1); ++y) {
                    for (z = World.validZ(region.getZ() - 1); z <= World.validZ(region.getZ() + 1); ++z) {
                        if (World.isNeighbour(currentRegion.getX(), currentRegion.getY(), currentRegion.getZ(), x, y, z)) continue;
                        World.getRegion(x, y, z).addToObservers(object, dropper);
                    }
                }
            }
        }
        if (object.isPlayer() && object.getReflection().isMain()) {
            int currentRegionMapY;
            int regionMapX = MapUtils.regionX(World.regionToCordX(region.getX()));
            int regionMapY = MapUtils.regionY(World.regionToCordY(region.getY()));
            int currentRegionMapX = currentRegion == null ? 0 : MapUtils.regionX(World.regionToCordX(currentRegion.getX()));
            int n = currentRegionMapY = currentRegion == null ? 0 : MapUtils.regionY(World.regionToCordY(currentRegion.getY()));
            if (regionMapX != currentRegionMapX || regionMapY != currentRegionMapY) {
                for (int triggerId : EventTriggersManager.getInstance().getTriggers(regionMapX, regionMapY)) {
                    object.getPlayer().sendPacket((IBroadcastPacket)new EventTriggerPacket(triggerId, true));
                }
            }
        }
    }

    public static void removeVisibleObject(GameObject object) {
        if (object == null || object.isVisible()) {
            return;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return;
        }
        object.setCurrentRegion(null);
        currentRegion.removeObject(object);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    World.getRegion(x, y, z).removeFromObservers(object);
                }
            }
        }
    }

    public static void forgetObject(GameObject object) {
        if (object == null) {
            return;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return;
        }
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    World.getRegion(x, y, z).forgetObject(object);
                }
            }
        }
    }

    public static GameObject getAroundObjectById(GameObject object, int objId) {
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return null;
        }
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (obj.getObjectId() != objId) continue;
                        return obj;
                    }
                }
            }
        }
        return null;
    }

    public static List<GameObject> getAroundObjects(GameObject object) {
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        LazyArrayList result = new LazyArrayList(128);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
                        result.add(obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<GameObject> getAroundObjects(GameObject object, int radius, int height) {
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        if (radius == -1) {
            ArrayList<GameObject> objects = new ArrayList<GameObject>();
            for (GameObject o : GameObjectsStorage.getObjects()) {
                if (o.getObjectId() == oid || o.getReflectionId() != rid) continue;
                objects.add(o);
            }
            return objects;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = object.getX();
        int oy = object.getY();
        int oz = object.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(128);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (obj.getObjectId() == oid || obj.getReflectionId() != rid || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add(obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Creature> getAroundCharacters(Location loc, int objectId, int reflectionId) {
        WorldRegion currentRegion = World.getRegion(loc);
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (!obj.isCreature() || obj.getObjectId() == objectId || obj.getReflectionId() != reflectionId) continue;
                        result.add((Creature)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Creature> getAroundCharacters(GameObject object) {
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (!obj.isCreature() || obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
                        result.add((Creature)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Creature> getAroundCharacters(Location loc, int objectId, int reflectionId, int radius, int height) {
        if (radius == -1) {
            ArrayList<Creature> characters = new ArrayList<Creature>();
            for (GameObject object : GameObjectsStorage.getObjects()) {
                if (!object.isCreature() || object.getObjectId() == objectId || object.getReflectionId() != reflectionId) continue;
                characters.add((Creature)object);
            }
            return characters;
        }
        WorldRegion currentRegion = World.getRegion(loc);
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = loc.getX();
        int oy = loc.getY();
        int oz = loc.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isCreature() || obj.getObjectId() == objectId || obj.getReflectionId() != reflectionId || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add((Creature)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Creature> getAroundCharacters(GameObject object, int radius, int height) {
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        if (radius == -1) {
            ArrayList<Creature> characters = new ArrayList<Creature>();
            for (GameObject o : GameObjectsStorage.getObjects()) {
                if (!o.isCreature() || o.getObjectId() == oid || o.getReflectionId() != rid) continue;
                characters.add((Creature)o);
            }
            return characters;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = object.getX();
        int oy = object.getY();
        int oz = object.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isCreature() || obj.getObjectId() == oid || obj.getReflectionId() != rid || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add((Creature)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Creature> getAroundAttackableCreatures(NpcInstance npc, int radius, int height) {
        int oid = npc.getObjectId();
        int rid = npc.getReflectionId();
        if (radius == -1) {
            ArrayList<Creature> creatures = new ArrayList<Creature>();
            for (GameObject o : GameObjectsStorage.getObjects()) {
                if (!o.isCreature() || o.getObjectId() == oid || o.getReflectionId() != rid) continue;
                Creature creature = (Creature)o;
                if (!npc.getAI().canAttackCharacter(creature)) continue;
                creatures.add(creature);
            }
            return creatures;
        }
        WorldRegion currentRegion = npc.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = npc.getX();
        int oy = npc.getY();
        int oz = npc.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isCreature() || obj.getObjectId() == oid || obj.getReflectionId() != rid || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        Creature creature = (Creature)obj;
                        if (!npc.getAI().canAttackCharacter(creature)) continue;
                        result.add(creature);
                    }
                }
            }
        }
        return result;
    }

    public static List<NpcInstance> getAroundNpc(GameObject object) {
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (!obj.isNpc() || obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
                        result.add((NpcInstance)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<NpcInstance> getAroundNpc(GameObject object, int radius, int height) {
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        if (radius == -1) {
            ArrayList<NpcInstance> npcs = new ArrayList<NpcInstance>();
            for (NpcInstance npc : GameObjectsStorage.getNpcs()) {
                if (npc.getObjectId() == oid || npc.getReflectionId() != rid) continue;
                npcs.add(npc);
            }
            return npcs;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = object.getX();
        int oy = object.getY();
        int oz = object.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isNpc() || obj.getObjectId() == oid || obj.getReflectionId() != rid || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add((NpcInstance)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<NpcInstance> getAroundNpc(Location loc, WorldRegion region, int reflect, int radius, int height) {
        int rid = reflect;
        if (radius == -1) {
            ArrayList<NpcInstance> npcs = new ArrayList<NpcInstance>();
            for (NpcInstance npc : GameObjectsStorage.getNpcs()) {
                if (npc.getReflectionId() != rid) continue;
                npcs.add(npc);
            }
            return npcs;
        }
        WorldRegion currentRegion = region;
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = loc.x;
        int oy = loc.y;
        int oz = loc.z;
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isNpc() || obj.getReflectionId() != rid || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add((NpcInstance)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Playable> getAroundPlayables(GameObject object) {
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (!obj.isPlayable() || obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
                        result.add((Playable)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Playable> getAroundPlayables(GameObject object, int radius, int height) {
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        if (radius == -1) {
            ArrayList<Playable> playables = new ArrayList<Playable>();
            for (GameObject o : GameObjectsStorage.getObjects()) {
                if (!o.isPlayable() || o.getObjectId() == oid || o.getReflectionId() != rid) continue;
                playables.add((Playable)o);
            }
            return playables;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = object.getX();
        int oy = object.getY();
        int oz = object.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isPlayable() || obj.getObjectId() == oid || obj.getReflectionId() != rid || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add((Playable)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Player> getAroundPlayers(GameObject object) {
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (!obj.isPlayer() || obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
                        result.add((Player)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Player> getAroundPlayers(GameObject object, int radius) {
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        if (radius == -1) {
            ArrayList<Player> players = new ArrayList<Player>();
            for (Player player : GameObjectsStorage.getPlayers(true, true)) {
                if (player.getObjectId() == oid || player.getReflectionId() != rid) continue;
                players.add(player);
            }
            return players;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = object.getX();
        int oy = object.getY();
        int oz = object.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isPlayer() || obj.getObjectId() == oid || obj.getReflectionId() != rid || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add((Player)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Player> getAroundPlayers(GameObject object, int radius, int height) {
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        if (radius == -1) {
            ArrayList<Player> players = new ArrayList<Player>();
            for (Player player : GameObjectsStorage.getPlayers(true, true)) {
                if (player.getObjectId() == oid || player.getReflectionId() != rid) continue;
                players.add(player);
            }
            return players;
        }
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int ox = object.getX();
        int oy = object.getY();
        int oz = object.getZ();
        int sqrad = radius * radius;
        LazyArrayList result = new LazyArrayList(64);
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        int dy;
                        int dx;
                        if (!obj.isPlayer() || obj.getObjectId() == oid || obj.getReflectionId() != rid || Math.abs(obj.getZ() - oz) > height || (dx = Math.abs(obj.getX() - ox)) > radius || (dy = Math.abs(obj.getY() - oy)) > radius || dx * dx + dy * dy > sqrad) continue;
                        result.add((Player)obj);
                    }
                }
            }
        }
        return result;
    }

    public static List<Player> getAroundObservers(Location loc) {
        WorldRegion currentRegion = World.getRegion(loc);
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        LazyArrayList result = new LazyArrayList(64);
        int x1 = World.validX(currentRegion.getX() + 1);
        int y0 = World.validY(currentRegion.getY() - 1);
        int y1 = World.validY(currentRegion.getY() + 1);
        int z0 = World.validZ(currentRegion.getZ() - 1);
        int z1 = World.validZ(currentRegion.getZ() + 1);
        for (int x = World.validX(currentRegion.getX() - 1); x <= x1; ++x) {
            for (int y = y0; y <= y1; ++y) {
                for (int z = z0; z <= z1; ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (!obj.isObservePoint() && !obj.isPlayer() || obj.isPlayer() && ((Player)obj).isInObserverMode()) continue;
                        result.add(obj.getPlayer());
                    }
                }
            }
        }
        return result;
    }

    public static List<Player> getAroundObservers(GameObject object) {
        WorldRegion currentRegion = object.getCurrentRegion();
        if (currentRegion == null) {
            return Collections.emptyList();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        LazyArrayList result = new LazyArrayList(64);
        int x1 = World.validX(currentRegion.getX() + 1);
        int y0 = World.validY(currentRegion.getY() - 1);
        int y1 = World.validY(currentRegion.getY() + 1);
        int z0 = World.validZ(currentRegion.getZ() - 1);
        int z1 = World.validZ(currentRegion.getZ() + 1);
        for (int x = World.validX(currentRegion.getX() - 1); x <= x1; ++x) {
            for (int y = y0; y <= y1; ++y) {
                for (int z = z0; z <= z1; ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (obj.getObjectId() == oid || obj.getReflectionId() != rid || !obj.isObservePoint() && !obj.isPlayer() || obj.isPlayer() && ((Player)obj).isInObserverMode()) continue;
                        result.add(obj.getPlayer());
                    }
                }
            }
        }
        return result;
    }

    public static List<Player> getPlayersOnMap(int mapX, int mapY) {
        return World.getPlayersOnMap(mapX, mapY, 0, null);
    }

    public static List<Player> getPlayersOnMap(int mapX, int mapY, int offset) {
        return World.getPlayersOnMap(mapX, mapY, offset, null);
    }

    public static List<Player> getPlayersOnMap(int mapX, int mapY, int offset, Reflection reflection) {
        ArrayList<Player> list = new ArrayList<Player>();
        for (Player player : GameObjectsStorage.getPlayers(true, true)) {
            if (reflection != null && player.getReflection() != reflection) continue;
            int tx = MapUtils.regionX(player);
            int ty = MapUtils.regionY(player);
            if (tx < mapX - offset || tx > mapX + offset || ty < mapY - offset || ty > mapY + offset) continue;
            list.add(player);
        }
        return list;
    }

    public static boolean isNeighborsEmpty(WorldRegion region) {
        for (int x = World.validX(region.getX() - 1); x <= World.validX(region.getX() + 1); ++x) {
            for (int y = World.validY(region.getY() - 1); y <= World.validY(region.getY() + 1); ++y) {
                for (int z = World.validZ(region.getZ() - 1); z <= World.validZ(region.getZ() + 1); ++z) {
                    if (World.getRegion(x, y, z).isEmpty()) continue;
                    return false;
                }
            }
        }
        return true;
    }

    public static void activate(WorldRegion currentRegion) {
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    World.getRegion(x, y, z).setActive(true);
                }
            }
        }
    }

    public static void deactivate(WorldRegion currentRegion) {
        for (int x = World.validX(currentRegion.getX() - 1); x <= World.validX(currentRegion.getX() + 1); ++x) {
            for (int y = World.validY(currentRegion.getY() - 1); y <= World.validY(currentRegion.getY() + 1); ++y) {
                for (int z = World.validZ(currentRegion.getZ() - 1); z <= World.validZ(currentRegion.getZ() + 1); ++z) {
                    if (!World.isNeighborsEmpty(World.getRegion(x, y, z))) continue;
                    World.getRegion(x, y, z).setActive(false);
                }
            }
        }
    }

    public static void showObjectsToPlayer(Player player) {
        WorldRegion currentRegion = player.getCurrentRegion();
        if (currentRegion == null) {
            return;
        }
        int oid = player.getObjectId();
        int rid = player.getReflectionId();
        int x1 = World.validX(currentRegion.getX() + 1);
        int y0 = World.validY(currentRegion.getY() - 1);
        int y1 = World.validY(currentRegion.getY() + 1);
        int z0 = World.validZ(currentRegion.getZ() - 1);
        int z1 = World.validZ(currentRegion.getZ() + 1);
        for (int x = World.validX(currentRegion.getX() - 1); x <= x1; ++x) {
            for (int y = y0; y <= y1; ++y) {
                for (int z = z0; z <= z1; ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
                        player.sendPacket(player.addVisibleObject(obj, null));
                    }
                }
            }
        }
    }

    public static void removeObjectsFromPlayer(Player player) {
        WorldRegion currentRegion = player.getCurrentRegion();
        if (currentRegion == null) {
            return;
        }
        int oid = player.getObjectId();
        int rid = player.getReflectionId();
        int x1 = World.validX(currentRegion.getX() + 1);
        int y0 = World.validY(currentRegion.getY() - 1);
        int y1 = World.validY(currentRegion.getY() + 1);
        int z0 = World.validZ(currentRegion.getZ() - 1);
        int z1 = World.validZ(currentRegion.getZ() + 1);
        for (int x = World.validX(currentRegion.getX() - 1); x <= x1; ++x) {
            for (int y = y0; y <= y1; ++y) {
                for (int z = z0; z <= z1; ++z) {
                    for (GameObject obj : World.getRegion(x, y, z)) {
                        if (obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
                        player.sendPacket(player.removeVisibleObject(obj, null));
                    }
                }
            }
        }
    }

    public static void removeObjectFromPlayers(GameObject object) {
        List<L2GameServerPacket> d = null;
        for (Player p : World.getAroundObservers(object)) {
            p.sendPacket(p.removeVisibleObject(object, d == null ? object.deletePacketList(p) : d));
        }
    }

    static void addZone(Zone zone) {
        int y;
        int x;
        Reflection reflection = zone.getReflection();
        Territory territory = zone.getTerritory();
        if (territory == null) {
            _log.info("World: zone - " + zone.getName() + " not has territory.");
            return;
        }
        for (x = World.validX(World.regionX(territory.getXmin())); x <= World.validX(World.regionX(territory.getXmax())); ++x) {
            for (y = World.validY(World.regionY(territory.getYmin())); y <= World.validY(World.regionY(territory.getYmax())); ++y) {
                for (int z = World.validZ(World.regionZ(territory.getZmin())); z <= World.validZ(World.regionZ(territory.getZmax())); ++z) {
                    WorldRegion region = World.getRegion(x, y, z);
                    region.addZone(zone);
                    for (GameObject obj : region) {
                        if (!obj.isCreature() || obj.getReflection() != reflection) continue;
                        ((Creature)obj).updateZones();
                    }
                }
            }
        }
        if (zone.getTemplate().getEventTriggerId() != 0) {
            for (x = MapUtils.regionX(territory.getXmin()); x <= MapUtils.regionX(territory.getXmax()); ++x) {
                for (y = MapUtils.regionY(territory.getYmin()); y <= MapUtils.regionY(territory.getYmax()); ++y) {
                    EventTriggersManager.getInstance().addTrigger(x, y, zone.getTemplate().getEventTriggerId());
                }
            }
        }
    }

    static void removeZone(Zone zone) {
        int y;
        int x;
        Reflection reflection = zone.getReflection();
        Territory territory = zone.getTerritory();
        if (territory == null) {
            _log.info("World: zone - " + zone.getName() + " not has territory.");
            return;
        }
        for (x = World.validX(World.regionX(territory.getXmin())); x <= World.validX(World.regionX(territory.getXmax())); ++x) {
            for (y = World.validY(World.regionY(territory.getYmin())); y <= World.validY(World.regionY(territory.getYmax())); ++y) {
                for (int z = World.validZ(World.regionZ(territory.getZmin())); z <= World.validZ(World.regionZ(territory.getZmax())); ++z) {
                    WorldRegion region = World.getRegion(x, y, z);
                    region.removeZone(zone);
                    for (GameObject obj : region) {
                        if (!obj.isCreature() || obj.getReflection() != reflection) continue;
                        ((Creature)obj).updateZones();
                    }
                }
            }
        }
        if (zone.getTemplate().getEventTriggerId() != 0) {
            for (x = MapUtils.regionX(territory.getXmin()); x <= MapUtils.regionX(territory.getXmax()); ++x) {
                for (y = MapUtils.regionY(territory.getYmin()); y <= MapUtils.regionY(territory.getYmax()); ++y) {
                    EventTriggersManager.getInstance().removeTrigger(x, y, zone.getTemplate().getEventTriggerId());
                }
            }
        }
    }

    public static void getZones(Collection<Zone> inside, Location loc, Reflection reflection) {
        WorldRegion region = World.getRegion(loc);
        Zone[] zones = region.getZones();
        if (zones.length == 0) {
            return;
        }
        for (Zone zone : zones) {
            if (!zone.checkIfInZone(loc.x, loc.y, loc.z, reflection)) continue;
            inside.add(zone);
        }
    }

    public static void getZones(Collection<Zone> inside, int x, int y, Reflection reflection) {
        WorldRegion[][] regionsByX = _worldRegions[World.validX(World.regionX(x))];
        if (regionsByX == null) {
            return;
        }
        WorldRegion[] regionsByXY = regionsByX[World.validY(World.regionY(y))];
        if (regionsByXY == null) {
            return;
        }
        for (WorldRegion region : regionsByXY) {
            Zone[] zones;
            if (region == null || (zones = region.getZones()).length == 0) continue;
            for (Zone zone : zones) {
                if (!zone.isActive() || zone.getReflection() != reflection || !zone.checkIfInZone(x, y)) continue;
                inside.add(zone);
            }
        }
    }

    public static boolean isWater(Location loc, Reflection reflection) {
        return World.getWater(loc, reflection) != null;
    }

    public static Zone getWater(Location loc, Reflection reflection) {
        WorldRegion region = World.getRegion(loc);
        Zone[] zones = region.getZones();
        if (zones.length == 0) {
            return null;
        }
        for (Zone zone : zones) {
            if (zone == null || zone.getType() != Zone.ZoneType.water || !zone.checkIfInZone(loc.x, loc.y, loc.z, reflection)) continue;
            return zone;
        }
        return null;
    }

    public static int[] getStats() {
        int[] ret = new int[32];
        for (int x = 0; x <= REGIONS_X; ++x) {
            for (int y = 0; y <= REGIONS_Y; ++y) {
                for (int z = 0; z <= REGIONS_Z; ++z) {
                    ret[0] = ret[0] + 1;
                    WorldRegion region = _worldRegions[x][y][z];
                    if (region != null) {
                        if (region.isActive()) {
                            ret[1] = ret[1] + 1;
                        } else {
                            ret[2] = ret[2] + 1;
                        }
                        for (GameObject obj : region) {
                            ret[10] = ret[10] + 1;
                            if (obj.isCreature()) {
                                ret[11] = ret[11] + 1;
                                if (obj.isPlayer()) {
                                    ret[12] = ret[12] + 1;
                                    Player p = (Player)obj;
                                    if (!p.isInOfflineMode()) continue;
                                    ret[13] = ret[13] + 1;
                                    continue;
                                }
                                if (obj.isNpc()) {
                                    NpcInstance npc;
                                    ret[14] = ret[14] + 1;
                                    if (obj.isMonster()) {
                                        ret[16] = ret[16] + 1;
                                        if (obj.isMinion()) {
                                            ret[17] = ret[17] + 1;
                                        }
                                    }
                                    if (!(npc = (NpcInstance)obj).hasAI() || !npc.getAI().isActive()) continue;
                                    ret[15] = ret[15] + 1;
                                    continue;
                                }
                                if (obj.isPlayable()) {
                                    ret[18] = ret[18] + 1;
                                    continue;
                                }
                                if (!obj.isDoor()) continue;
                                ret[19] = ret[19] + 1;
                                continue;
                            }
                            if (!obj.isItem()) continue;
                            ret[20] = ret[20] + 1;
                        }
                        continue;
                    }
                    ret[3] = ret[3] + 1;
                }
            }
        }
        return ret;
    }
}
