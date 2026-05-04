/*
 * This file was originally decompiled from L2S rev.[31495].
 * Refactored: replaced synchronized(geodata) global lock with ReentrantReadWriteLock,
 * fixed string constants, removed CFR decompiler artifacts.
 */
package l2s.gameserver.geodata;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.hash.TIntHashSet;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import l2s.commons.geometry.CoordsConverter;
import l2s.commons.geometry.Point2D;
import l2s.commons.geometry.Polygon;
import l2s.commons.geometry.Shape;
import l2s.gameserver.Config;
import l2s.gameserver.geodata.GeoControl;
import l2s.gameserver.geodata.GeoCrypt;
import l2s.gameserver.geodata.GeoOptimizer;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.World;
import l2s.gameserver.model.WorldRegion;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.model.instances.FenceInstance;
import l2s.gameserver.templates.DoorTemplate;
import org.napile.primitive.pair.ByteObjectPair;
import org.napile.primitive.pair.impl.ByteObjectPairImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GeoEngine {
    private static final CoordsConverter WORLD_TO_GEO_COORD_CONVERTER = new CoordsConverter(){

        public int convertX(int x) {
            return GeoEngine.getGeoX(x);
        }

        public int convertY(int y) {
            return GeoEngine.getGeoY(y);
        }

        public int convertDistance(int distance) {
            return GeoEngine.getGeoDistance(distance);
        }
    };
    private static final Logger _log = LoggerFactory.getLogger(GeoEngine.class);
    public static final String L2S_EXTENSION = ".l2s";
    public static final String L2J_EXTENSION = ".l2j";
    public static final byte EAST = 1;
    public static final byte WEST = 2;
    public static final byte SOUTH = 4;
    public static final byte NORTH = 8;
    public static final byte NSWE_ALL = 15;
    public static final byte NSWE_NONE = 0;
    public static final byte BLOCKTYPE_FLAT = 0;
    public static final byte BLOCKTYPE_COMPLEX = 1;
    public static final byte BLOCKTYPE_MULTILEVEL = 2;
    public static final int BLOCKS_IN_MAP = 65536;
    private static final int DOOR_MAX_Z_DIFF = 256;
    public static final int LINEAR_TERRITORY_CELL_SIZE = GeoEngine.getWorldDistance(1);
    public static int MAX_LAYERS = 1;
    private static final TIntObjectMap<Set<GeoControl>> _activeGeoControls = new TIntObjectHashMap();
    private static byte[][][][][] geodata = new byte[9999][][][][];

    private static final java.util.concurrent.locks.ReentrantReadWriteLock _geoLock = new java.util.concurrent.locks.ReentrantReadWriteLock();
    private static final java.util.concurrent.locks.Lock _geoReadLock = _geoLock.readLock();
    private static final java.util.concurrent.locks.Lock _geoWriteLock = _geoLock.writeLock();

    public static int getMapX(int x) {
        return (x - World.MAP_MIN_X >> 15) + Config.GEO_X_FIRST;
    }

    public static int getMapY(int y) {
        return (y - World.MAP_MIN_Y >> 15) + Config.GEO_Y_FIRST;
    }

    public static short getType(int x, int y, int geoIndex) {
        return GeoEngine.NgetType(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), geoIndex);
    }

    public static int correctGeoZ(int x, int y, int z, int geoIndex) {
        int correctedZ = GeoEngine.getLowerHeight(x, y, z, geoIndex);
        if (correctedZ == Short.MIN_VALUE && (correctedZ = GeoEngine.getUpperHeight(x, y, z, geoIndex)) == Short.MAX_VALUE) {
            correctedZ = z;
        }
        return correctedZ;
    }

    /**
     * Validates and corrects spawn height. If geodata exists at the location,
     * searches for the nearest lower surface within SPAWN_HEIGHT_OFFSET range.
     * Returns corrected height only if the difference is within SPAWN_Z_DELTA_LIMIT,
     * otherwise returns the original Z to avoid spawning inside terrain.
     */
    public static int getSpawnHeight(int x, int y, int z, int geoIndex)
    {
        if (!GeoEngine.hasGeo(x, y, geoIndex))
        {
            return z;
        }

        int nextLowerZ = GeoEngine.getLowerHeight(x, y, z + Config.SPAWN_HEIGHT_OFFSET, geoIndex);

        if (nextLowerZ == Short.MIN_VALUE)
        {
            return z;
        }

        return Math.abs(nextLowerZ - z) <= Config.SPAWN_Z_DELTA_LIMIT ? nextLowerZ : z;
    }

    public static int getLowerHeight(ILocation loc, int geoIndex) {
        return GeoEngine.getLowerHeight(loc.getX(), loc.getY(), loc.getZ(), geoIndex);
    }

    public static int getLowerHeight(int x, int y, int z, int geoIndex) {
        return GeoEngine.NgetLowerHeight(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), (short)Math.min(z, Short.MAX_VALUE), geoIndex);
    }

    public static int getUpperHeight(ILocation loc, int geoIndex) {
        return GeoEngine.getUpperHeight(loc.getX(), loc.getY(), loc.getZ(), geoIndex);
    }

    public static int getUpperHeight(int x, int y, int z, int geoIndex) {
        return GeoEngine.NgetUpperHeight(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), (short)Math.min(z, Short.MAX_VALUE), geoIndex);
    }

    public static int getLowerNSWE(ILocation loc, int geoIndex) {
        return GeoEngine.getLowerNSWE(loc.getX(), loc.getY(), loc.getZ(), geoIndex);
    }

    public static byte getLowerNSWE(int x, int y, int z, int geoIndex) {
        return GeoEngine.NgetLowerNSWE(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), (short)Math.min(z, Short.MAX_VALUE), geoIndex);
    }

    public static int getUpperNSWE(ILocation loc, int geoIndex) {
        return GeoEngine.getUpperNSWE(loc.getX(), loc.getY(), loc.getZ(), geoIndex);
    }

    public static byte getUpperNSWE(int x, int y, int z, int geoIndex) {
        return GeoEngine.NgetUpperNSWE(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), (short)Math.min(z, Short.MAX_VALUE), geoIndex);
    }

    public static short[] getLowerHeightAndNSWE(ILocation loc, int geoIndex) {
        return GeoEngine.getLowerHeightAndNSWE(loc.getX(), loc.getY(), loc.getZ(), geoIndex);
    }

    public static short[] getLowerHeightAndNSWE(int x, int y, int z, int geoIndex) {
        short[] result = new short[2];
        GeoEngine.NgetLowerHeightAndNSWE(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), (short)Math.min(z, Short.MAX_VALUE), result, geoIndex);
        return result;
    }

    public static short[] getUpperHeightAndNSWE(ILocation loc, int geoIndex) {
        return GeoEngine.getUpperHeightAndNSWE(loc.getX(), loc.getY(), loc.getZ(), geoIndex);
    }

    public static short[] getUpperHeightAndNSWE(int x, int y, int z, int geoIndex) {
        short[] result = new short[2];
        GeoEngine.NgetUpperHeightAndNSWE(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), (short)Math.min(z, Short.MAX_VALUE), result, geoIndex);
        return result;
    }

    public static boolean canMoveToCoord(int x, int y, int z, int tx, int ty, int tz, int geoIndex) {
        if (checkIfDoorsBetween(x, y, z, tx, ty, tz)) {
            return false;
        }
        if (checkIfFenceBetween(x, y, z, tx, ty, tz)) {
            return false;
        }
        return GeoEngine.canMove(x, y, z, tx, ty, tz, false, geoIndex);
    }

    public static Location moveCheck(int x, int y, int z, int tx, int ty, boolean withCollision, boolean backwardMove, boolean returnPrev, int geoIndex) {
        int tgy;
        int tgx;
        int gy;
        int gx = GeoEngine.getGeoX(x);
        Location result = GeoEngine.MoveCheck(gx, gy = GeoEngine.getGeoY(y), z, tgx = GeoEngine.getGeoX(tx), tgy = GeoEngine.getGeoY(ty), withCollision, backwardMove, returnPrev, geoIndex);
        if (result.equals(gx, gy, z)) {
            return null;
        }
        return result.geo2world();
    }

    public static Location moveCheck(int x, int y, int z, int tx, int ty, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, false, false, false, geoIndex);
    }

    public static Location moveCheck(int x, int y, int z, int tx, int ty, boolean returnPrev, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, false, false, returnPrev, geoIndex);
    }

    public static Location moveCheckWithCollision(int x, int y, int z, int tx, int ty, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, true, false, false, geoIndex);
    }

    public static Location moveCheckWithCollision(int x, int y, int z, int tx, int ty, boolean returnPrev, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, true, false, returnPrev, geoIndex);
    }

    public static Location moveCheckBackward(int x, int y, int z, int tx, int ty, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, false, true, false, geoIndex);
    }

    public static Location moveCheckBackward(int x, int y, int z, int tx, int ty, boolean returnPrev, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, false, true, returnPrev, geoIndex);
    }

    public static Location moveCheckBackwardWithCollision(int x, int y, int z, int tx, int ty, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, true, true, false, geoIndex);
    }

    public static Location moveCheckBackwardWithCollision(int x, int y, int z, int tx, int ty, boolean returnPrev, int geoIndex) {
        return GeoEngine.moveCheck(x, y, z, tx, ty, true, true, returnPrev, geoIndex);
    }

    public static Location moveInWaterCheck(Creature actor, int tx, int ty, int tz, int[] limits) {
        int gx = GeoEngine.getGeoX(actor.getX());
        int gy = GeoEngine.getGeoY(actor.getY());
        int z = actor.getZ();
        int h = (int)actor.getCurrentCollisionHeight();
        int tgx = GeoEngine.getGeoX(tx);
        int tgy = GeoEngine.getGeoY(ty);
        return GeoEngine.MoveInWaterCheck(gx, gy, z, tgx, tgy, tz, actor.getGeoIndex(), limits[0], limits[1]);
    }

    private static Location MoveInWaterCheck(int x, int y, int z, int tx, int ty, int tz, int geoIndex, int minZ, int maxZ) {
        int dx = tx - x;
        int dy = ty - y;
        int dz = tz - z;
        byte inc_x = GeoEngine.sign(dx);
        byte inc_y = GeoEngine.sign(dy);
        if ((dx = Math.abs(dx)) + (dy = Math.abs(dy)) == 0) {
            return new Location(x, y, z).geo2world();
        }
        float inc_z_for_x = dx == 0 ? 0.0f : (float)(dz / dx);
        float inc_z_for_y = dy == 0 ? 0.0f : (float)(dz / dy);
        float next_x = x;
        float next_y = y;
        float next_z = z;
        if (dx >= dy) {
            int delta_A = 2 * dy;
            int d = delta_A - dx;
            int delta_B = delta_A - 2 * dx;
            for (int i = 0; i < dx; ++i) {
                int prev_x = x;
                int prev_y = y;
                int prev_z = z;
                x = (int)next_x;
                y = (int)next_y;
                z = (int)next_z;
                if (d > 0) {
                    d += delta_B;
                    next_x += (float)inc_x;
                    next_z += inc_z_for_x;
                    next_y += (float)inc_y;
                    next_z += inc_z_for_y;
                } else {
                    d += delta_A;
                    next_x += (float)inc_x;
                    next_z += inc_z_for_x;
                }
                if (!(next_z < (float)minZ) && !(next_z >= (float)maxZ) && GeoEngine.NLOS_WATER(x, y, z, (int)next_x, (int)next_y, (int)next_z, geoIndex)) continue;
                return new Location(prev_x, prev_y, prev_z).geo2world();
            }
        } else {
            int delta_A = 2 * dx;
            int d = delta_A - dy;
            int delta_B = delta_A - 2 * dy;
            for (int i = 0; i < dy; ++i) {
                int prev_x = x;
                int prev_y = y;
                int prev_z = z;
                x = (int)next_x;
                y = (int)next_y;
                z = (int)next_z;
                if (d > 0) {
                    d += delta_B;
                    next_x += (float)inc_x;
                    next_z += inc_z_for_x;
                    next_y += (float)inc_y;
                    next_z += inc_z_for_y;
                } else {
                    d += delta_A;
                    next_y += (float)inc_y;
                    next_z += inc_z_for_y;
                }
                if (!(next_z < (float)minZ) && !(next_z >= (float)maxZ) && GeoEngine.NLOS_WATER(x, y, z, (int)next_x, (int)next_y, (int)next_z, geoIndex)) continue;
                return new Location(prev_x, prev_y, prev_z).geo2world();
            }
        }
        return new Location((int)next_x, (int)next_y, (int)next_z).geo2world();
    }

    private static boolean NLOS_WATER(int x, int y, int z, int next_x, int next_y, int next_z, int geoIndex) {
        short h;
        short[] layers1 = new short[MAX_LAYERS + 1];
        short[] layers2 = new short[MAX_LAYERS + 1];
        GeoEngine.NGetLayers(x, y, layers1, geoIndex);
        GeoEngine.NGetLayers(next_x, next_y, layers2, geoIndex);
        if (layers1[0] == 0 || layers2[0] == 0) {
            return true;
        }
        int z2 = Short.MIN_VALUE;
        for (int i = 1; i <= layers2[0]; ++i) {
            h = (short)((short)(layers2[i] & 0xFFF0) >> 1);
            if (Math.abs(next_z - z2) <= Math.abs(next_z - h)) continue;
            z2 = h;
        }
        if (next_z + LINEAR_TERRITORY_CELL_SIZE >= z2) {
            return true;
        }
        int z3 = Short.MIN_VALUE;
        for (int i = 1; i <= layers2[0]; ++i) {
            h = (short)((short)(layers2[i] & 0xFFF0) >> 1);
            if (h >= z2 + Config.MIN_LAYER_HEIGHT || Math.abs(next_z - z3) <= Math.abs(next_z - h)) continue;
            z3 = h;
        }
        if (z3 == Short.MIN_VALUE) {
            return false;
        }
        int z1 = Short.MIN_VALUE;
        byte NSWE1 = 15;
        for (int i = 1; i <= layers1[0]; ++i) {
            h = (short)((short)(layers1[i] & 0xFFF0) >> 1);
            if (h >= z + Config.MIN_LAYER_HEIGHT || Math.abs(z - z1) <= Math.abs(z - h)) continue;
            z1 = h;
            NSWE1 = (byte)(layers1[i] & 0xF);
        }
        return GeoEngine.checkNSWE(NSWE1, x, y, next_x, next_y);
    }

    public static Location moveCheckForAI(ILocation loc1, ILocation loc2, int geoIndex) {
        int gx = GeoEngine.getGeoX(loc1.getX());
        int gy = GeoEngine.getGeoY(loc1.getY());
        int tgx = GeoEngine.getGeoX(loc2.getX());
        int tgy = GeoEngine.getGeoY(loc2.getY());
        Location result = GeoEngine.MoveCheckForAI(gx, gy, loc1.getZ(), tgx, tgy, geoIndex);
        if (result.equals(gx, gy, loc1.getZ())) {
            return null;
        }
        return result.geo2world();
    }

    public static Location moveCheckInAir(Creature actor, int tx, int ty, int tz) {
        int tgy;
        int gx = GeoEngine.getGeoX(actor.getX());
        int gy = GeoEngine.getGeoY(actor.getY());
        int z = actor.getZ();
        int h = (int)actor.getCurrentCollisionHeight();
        int tgx = GeoEngine.getGeoX(tx);
        Location result = GeoEngine.canSee(gx, gy, z, tgx, tgy = GeoEngine.getGeoY(ty), tz, true, actor.getGeoIndex(), -15000, 15000, false);
        if (result.equals(gx, gy, z)) {
            return null;
        }
        return result.geo2world();
    }

    public static boolean canSeeTarget(GameObject actor, GameObject target) {
        if (actor == null || target == null) {
            return false;
        }
        if (actor.equals(target)) {
            return true;
        }
        return GeoEngine.canSeeCoord(actor, target.getX(), target.getY(), target.getZ(), (int)target.getCurrentCollisionHeight(), (int)target.getCurrentCollisionRadius(), target.isFlying() || target.isInWater());
    }

    public static boolean canSeeCoord(GameObject actor, int tx, int ty, int tz, boolean tAirOrWater) {
        return GeoEngine.canSeeCoord(actor, tx, ty, tz, 0, 0, tAirOrWater);
    }

    public static boolean canSeeCoord(GameObject actor, int tx, int ty, int tz, int th, int tr, boolean tAirOrWater) {
        if (actor == null) {
            return false;
        }
        return GeoEngine.canSeeCoord(actor.getX(), actor.getY(), actor.getZ(), (int)actor.getCurrentCollisionHeight(), (int)actor.getCurrentCollisionRadius(), actor.isFlying() || actor.isInWater(), tx, ty, tz, th, tr, tAirOrWater, actor.getGeoIndex(), actor.isPlayer());
    }

    public static boolean canSeeCoord(int x, int y, int z, boolean airOrWater, int tx, int ty, int tz, boolean tAirOrWater, int geoIndex, boolean debug) {
        return GeoEngine.canSeeCoord(x, y, z, 0, 0, airOrWater, tx, ty, tz, 0, 0, tAirOrWater, geoIndex, debug);
    }

    private static boolean canSeeCoord(int x, int y, int z, int h, int r, boolean airOrWater, int tx, int ty, int tz, int th, int tr, boolean tAirOrWater, int geoIndex, boolean debug) {
        int tmy;
        int tmx;
        int my;
        int mx = GeoEngine.getGeoX(x);
        if (GeoEngine.checkIsInSameGeoCeil(mx, my = GeoEngine.getGeoY(y), z, tmx = GeoEngine.getGeoX(tx), tmy = GeoEngine.getGeoY(ty), tz, geoIndex)) {
            return true;
        }
        if (checkIfDoorsBetween(x, y, z, tx, ty, tz)) {
            return false;
        }
        if (checkIfFenceBetween(x, y, z, tx, ty, tz)) {
            return false;
        }
        int mh = Math.max(0, h - h % 8 + 8) * 2;
        int mz = Math.min(z + mh, GeoEngine.NgetUpperHeight(mx, my, (short)Math.min(z, Short.MAX_VALUE), geoIndex) - Config.MIN_LAYER_HEIGHT);
        int tmh = Math.max(0, th - th % 8 + 8) * 2;
        int tmz = Math.min(tz + tmh, GeoEngine.NgetUpperHeight(tmx, tmy, (short)Math.min(tz, Short.MAX_VALUE), geoIndex) - Config.MIN_LAYER_HEIGHT);
        for (int i = 0; i <= tmh; i += 2) {
            if (GeoEngine.canSee(mx, my, mz, tmx, tmy, tmz, airOrWater, geoIndex, Integer.MIN_VALUE, Integer.MAX_VALUE, debug).equals(tmx, tmy, tmz) && GeoEngine.canSee(tmx, tmy, tmz, mx, my, mz, tAirOrWater, geoIndex, Integer.MIN_VALUE, Integer.MAX_VALUE, false).equals(mx, my, mz)) {
                return true;
            }
            --tmz;
        }
        return false;
    }

    private static boolean checkIsInSameGeoCeil(int mx, int my, int z, int tmx, int tmy, int tz, int geoIndex) {
        if (mx == tmx && my == tmy) {
            int theight;
            if (!Config.ALLOW_GEODATA) {
                return true;
            }
            int height = GeoEngine.NgetLowerHeight(mx, my, (short)Math.min(z, Short.MAX_VALUE), geoIndex);
            if (height == (theight = GeoEngine.NgetLowerHeight(tmx, tmy, (short)Math.min(tz, Short.MAX_VALUE), geoIndex))) {
                return true;
            }
        }
        return false;
    }

    public static boolean canMoveWithCollision(int x, int y, int z, int tx, int ty, int tz, int geoIndex) {
        if (checkIfDoorsBetween(x, y, z, tx, ty, tz)) {
            return false;
        }
        if (checkIfFenceBetween(x, y, z, tx, ty, tz)) {
            return false;
        }
        return GeoEngine.canMove(x, y, z, tx, ty, tz, true, geoIndex);
    }

    public static boolean checkNSWE(byte NSWE, int x, int y, int tx, int ty) {
        if (NSWE == 15) {
            return true;
        }
        if (NSWE == 0) {
            return false;
        }
        if (tx > x ? (NSWE & 1) == 0 : tx < x && (NSWE & 2) == 0) {
            return false;
        }
        return !(ty > y ? (NSWE & 4) == 0 : ty < y && (NSWE & 8) == 0);
    }

    public static boolean hasGeo(int x, int y, int geoIndex) {
        return GeoEngine.getGeoBlockFromGeoCoords(GeoEngine.getGeoX(x), GeoEngine.getGeoY(y), geoIndex, false) != null;
    }

    public static String geoXYZ2Str(int _x, int _y, int _z) {
        return "(" + GeoEngine.getWorldX(_x) + " " + GeoEngine.getWorldY(_y) + " " + _z + ")";
    }

    public static String NSWE2Str(byte nswe) {
        String result = "";
        if ((nswe & 8) == 8) {
            result = result + "N";
        }
        if ((nswe & 4) == 4) {
            result = result + "S";
        }
        if ((nswe & 2) == 2) {
            result = result + "W";
        }
        if ((nswe & 1) == 1) {
            result = result + "E";
        }
        return result.isEmpty() ? "X" : result;
    }

    private static short FindNearestLowerLayer(short[] layers, int z, boolean regionEdge) {
        short nearest_layer_h = Short.MIN_VALUE;
        short nearest_layer = Short.MIN_VALUE;
        int zCheck = regionEdge ? z + Config.REGION_EDGE_MAX_Z_DIFF : z;
        for (int i = 1; i <= layers[0]; ++i) {
            short h = (short)((short)(layers[i] & 0xFFF0) >> 1);
            if (h > zCheck || nearest_layer_h > h) continue;
            nearest_layer_h = h;
            nearest_layer = layers[i];
        }
        return nearest_layer;
    }

    private static short[] CheckNoOneLayerInRangeAndFindNearestLowerLayer(short[] layers, int z0, int z1) {
        int z_min = Math.min(z0, z1);
        int z_max = Math.max(z0, z1);
        short layerid = Short.MIN_VALUE;
        short nearest_layer = Short.MIN_VALUE;
        short nearest_layer_h = Short.MIN_VALUE;
        for (int i = 1; i <= layers[0]; ++i) {
            short h = (short)((short)(layers[i] & 0xFFF0) >> 1);
            if (z_min < h && h < z_max) {
                return new short[]{Short.MIN_VALUE, Short.MIN_VALUE};
            }
            if (h > z_max || nearest_layer_h > h) continue;
            nearest_layer_h = h;
            nearest_layer = layers[i];
            layerid = (short)i;
        }
        return new short[]{layerid, nearest_layer};
    }

    private static short[] CheckNoOneLayerInRangeAndFindNearestHighestLayer(short[] layers, int z0, int z1) {
        int z_min = Math.min(z0, z1);
        int z_max = Math.max(z0, z1);
        short layerid = Short.MAX_VALUE;
        short nearest_layer = Short.MAX_VALUE;
        short nearest_layer_h = Short.MAX_VALUE;
        for (int i = layers[0]; i >= 1; --i) {
            short h = (short)((short)(layers[i] & 0xFFF0) >> 1);
            if (z_max >= h && h >= z_min) {
                return new short[]{Short.MAX_VALUE, Short.MAX_VALUE};
            }
            if (h <= z_min || nearest_layer_h <= h) continue;
            nearest_layer_h = h;
            nearest_layer = layers[i];
            layerid = (short)i;
        }
        return new short[]{layerid, nearest_layer};
    }

    public static boolean canSeeWallCheck(short[] lower_layer, short[] nearest_lower_neighbor, short[] highest_layer, short[] nearest_highest_neighbor, byte directionNSWE, int curr_z, boolean airOrWater, boolean debug) {
        int lower_z_diff;
        int lower_z_diff2;
        if (lower_layer[1] == nearest_highest_neighbor[1] || highest_layer[1] == nearest_lower_neighbor[1]) {
            return false;
        }
        if (highest_layer[1] == Short.MAX_VALUE && nearest_highest_neighbor[1] == Short.MAX_VALUE) {
            return true;
        }
        short nearest_highest_neighbor_h = (short)((short)(nearest_highest_neighbor[1] & 0xFFF0) >> 1);
        short nearest_lower_neighbor_h = (short)((short)(nearest_lower_neighbor[1] & 0xFFF0) >> 1);
        if (nearest_highest_neighbor_h < curr_z || nearest_lower_neighbor_h >= curr_z) {
            return false;
        }
        short lower_layer_h = (short)((short)(lower_layer[1] & 0xFFF0) >> 1);
        short highest_layer_h = (short)((short)(highest_layer[1] & 0xFFF0) >> 1);
        if (curr_z <= highest_layer_h && curr_z > lower_layer_h && curr_z <= nearest_highest_neighbor_h && curr_z > nearest_lower_neighbor_h && ((lower_z_diff2 = nearest_lower_neighbor_h - lower_layer_h) > -Config.MAX_Z_DIFF || lower_layer[0] == nearest_lower_neighbor[0] || highest_layer[0] == nearest_highest_neighbor[0])) {
            return true;
        }
        if (airOrWater) {
            return true;
        }
        byte lowerNSWE = (byte)(lower_layer[1] & 0xF);
        return (lowerNSWE & directionNSWE) == directionNSWE && ((lower_z_diff = nearest_lower_neighbor_h - lower_layer_h) > -Config.MAX_Z_DIFF || lower_layer[0] == nearest_lower_neighbor[0] || highest_layer[0] == nearest_highest_neighbor[0]);
    }

    private static Location canSee(int _x, int _y, int _z, int _tx, int _ty, int _tz, boolean airOrWater, int geoIndex, int minZ, int maxZ, boolean debug) {
        int diff_x = _tx - _x;
        int diff_y = _ty - _y;
        int diff_z = _tz - _z;
        int dx = Math.abs(diff_x);
        int dy = Math.abs(diff_y);
        int dz = Math.abs(diff_z);
        int steps = Math.max(Math.max(dx, dy), dz);
        int curr_x = _x;
        int curr_y = _y;
        int curr_z = _z;
        short[] curr_layers = new short[MAX_LAYERS + 1];
        GeoEngine.NGetLayers(curr_x, curr_y, curr_layers, geoIndex);
        Location result = new Location(_x, _y, _z, -1);
        if (steps == 0) {
            short[] layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestLowerLayer(curr_layers, curr_z, curr_z + diff_z);
            if (layer[1] != Short.MIN_VALUE) {
                result.set(_tx, _ty, _tz, 1);
            }
            return result;
        }
        short[] tmp_layers = new short[MAX_LAYERS + 1];
        GridLineIterator3D iter = new GridLineIterator3D(_x, _y, _z, _tx, _ty, _tz);
        iter.next(); // skip start point
        while (iter.next()) {
            int i_next_x = iter.x();
            int i_next_y = iter.y();
            int i_next_z = iter.z();
            if (curr_layers[0] == 0) {
                result.set(_tx, _ty, _tz, 0);
                return result;
            }
            if (i_next_z < minZ || i_next_z >= maxZ) {
                return result.setH(-10);
            }
            int middle_z = (curr_z + i_next_z) / 2;
            short[] src_nearest_lower_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestLowerLayer(curr_layers, curr_z, middle_z);
            if (src_nearest_lower_layer[1] == Short.MIN_VALUE) {
                return result.setH(-11);
            }
            short[] src_nearest_highest_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestHighestLayer(curr_layers, curr_z, middle_z);
            GeoEngine.NGetLayers(i_next_x, i_next_y, curr_layers, geoIndex);
            if (curr_layers[0] == 0) {
                result.set(_tx, _ty, _tz, 0);
                return result;
            }
            short[] dst_nearest_lower_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestLowerLayer(curr_layers, i_next_z, middle_z);
            if (dst_nearest_lower_layer[1] == Short.MIN_VALUE) {
                return result.setH(-12);
            }
            short[] dst_nearest_highest_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestHighestLayer(curr_layers, i_next_z, middle_z);
            if (curr_x == i_next_x) {
                if (!GeoEngine.canSeeWallCheck(src_nearest_lower_layer, dst_nearest_lower_layer, src_nearest_highest_layer, dst_nearest_highest_layer, i_next_y > curr_y ? (byte)4 : 8, curr_z, airOrWater, debug)) {
                    return result.setH(-20);
                }
            } else if (curr_y == i_next_y) {
                if (!GeoEngine.canSeeWallCheck(src_nearest_lower_layer, dst_nearest_lower_layer, src_nearest_highest_layer, dst_nearest_highest_layer, i_next_x > curr_x ? (byte)1 : 2, curr_z, airOrWater, debug)) {
                    return result.setH(-21);
                }
            } else {
                // Anti-corner-cut check for diagonal LOS step
                int dirNswe = (i_next_x > curr_x ? EAST : WEST) | (i_next_y > curr_y ? SOUTH : NORTH);
                if (!GeoEngine.checkNearestNsweAntiCornerCut(curr_x, curr_y, curr_z, dirNswe, geoIndex)) {
                    return result.setH(-25);
                }
                GeoEngine.NGetLayers(curr_x, i_next_y, tmp_layers, geoIndex);
                if (tmp_layers[0] == 0) {
                    result.set(_tx, _ty, _tz, 0);
                    return result;
                }
                short[] tmp_nearest_lower_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestLowerLayer(tmp_layers, i_next_z, middle_z);
                if (tmp_nearest_lower_layer[1] == Short.MIN_VALUE) {
                    return result.setH(-30);
                }
                short[] tmp_nearest_highest_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestHighestLayer(tmp_layers, i_next_z, middle_z);
                if (!GeoEngine.canSeeWallCheck(src_nearest_lower_layer, tmp_nearest_lower_layer, src_nearest_highest_layer, tmp_nearest_highest_layer, i_next_x > curr_x ? (byte)1 : 2, curr_z, airOrWater, debug)) {
                    return result.setH(-32);
                }
                if (!GeoEngine.canSeeWallCheck(tmp_nearest_lower_layer, dst_nearest_lower_layer, tmp_nearest_highest_layer, dst_nearest_highest_layer, i_next_x > curr_x ? (byte)1 : 2, curr_z, airOrWater, debug)) {
                    return result.setH(-34);
                }
                GeoEngine.NGetLayers(i_next_x, curr_y, tmp_layers, geoIndex);
                if (tmp_layers[0] == 0) {
                    result.set(_tx, _ty, _tz, 0);
                    return result;
                }
                tmp_nearest_lower_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestLowerLayer(tmp_layers, i_next_z, middle_z);
                if (tmp_nearest_lower_layer[1] == Short.MIN_VALUE) {
                    return result.setH(-35);
                }
                tmp_nearest_highest_layer = GeoEngine.CheckNoOneLayerInRangeAndFindNearestHighestLayer(tmp_layers, i_next_z, middle_z);
                if (!GeoEngine.canSeeWallCheck(src_nearest_lower_layer, tmp_nearest_lower_layer, src_nearest_highest_layer, tmp_nearest_highest_layer, i_next_y > curr_y ? (byte)4 : 8, curr_z, airOrWater, debug)) {
                    return result.setH(-32);
                }
                if (!GeoEngine.canSeeWallCheck(tmp_nearest_lower_layer, dst_nearest_lower_layer, tmp_nearest_highest_layer, dst_nearest_highest_layer, i_next_y > curr_y ? (byte)4 : 8, curr_z, airOrWater, debug)) {
                    return result.setH(-33);
                }
            }
            result.set(curr_x, curr_y, curr_z);
            curr_x = i_next_x;
            curr_y = i_next_y;
            curr_z = i_next_z;
        }
        result.set(_tx, _ty, _tz, 255);
        return result;
    }

    private static boolean canMove(int __x, int __y, int _z, int __tx, int __ty, int _tz, boolean withCollision, int geoIndex) {
        int el;
        int es;
        byte pdy;
        byte pdx;
        boolean overRegionEdge;
        int _x = GeoEngine.getGeoX(__x);
        int _y = GeoEngine.getGeoY(__y);
        int _tx = GeoEngine.getGeoX(__tx);
        int _ty = GeoEngine.getGeoY(__ty);
        int diff_x = _tx - _x;
        int diff_y = _ty - _y;
        byte incx = GeoEngine.sign(diff_x);
        byte incy = GeoEngine.sign(diff_y);
        boolean bl = overRegionEdge = _x >> 11 != _tx >> 11 || _y >> 11 != _ty >> 11;
        if (diff_x < 0) {
            diff_x = -diff_x;
        }
        if (diff_y < 0) {
            diff_y = -diff_y;
        }
        if (diff_x > diff_y) {
            pdx = incx;
            pdy = 0;
            es = diff_y;
            el = diff_x;
        } else {
            pdx = 0;
            pdy = incy;
            es = diff_x;
            el = diff_y;
        }
        int err = el / 2;
        int curr_x = _x;
        int curr_y = _y;
        int curr_z = _z;
        int next_x = curr_x;
        int next_y = curr_y;
        int next_z = curr_z;
        short[] next_layers = new short[MAX_LAYERS + 1];
        short[] temp_layers = new short[MAX_LAYERS + 1];
        short[] curr_layers = new short[MAX_LAYERS + 1];
        GeoEngine.NGetLayers(curr_x, curr_y, curr_layers, geoIndex);
        if (curr_layers[0] == 0) {
            return true;
        }
        for (int i = 0; i < el; ++i) {
            if ((err -= es) < 0) {
                err += el;
                next_x += incx;
                next_y += incy;
            } else {
                next_x += pdx;
                next_y += pdy;
            }
            boolean regionEdge = overRegionEdge && (next_x >> 11 != curr_x >> 11 || next_y >> 11 != curr_y >> 11);
            GeoEngine.NGetLayers(next_x, next_y, next_layers, geoIndex);
            next_z = GeoEngine.NcanMoveNext(curr_x, curr_y, curr_z, curr_layers, next_x, next_y, next_layers, temp_layers, withCollision, regionEdge, geoIndex);
            if (next_z == Integer.MIN_VALUE) {
                return false;
            }
            short[] t = curr_layers;
            curr_layers = next_layers;
            next_layers = t;
            curr_x = next_x;
            curr_y = next_y;
            curr_z = next_z;
        }
        int diff_z = curr_z - _tz;
        if (Config.ALLOW_FALL_FROM_WALLS) {
            return diff_z < Config.MAX_Z_DIFF;
        }
        if (diff_z < 0) {
            diff_z = -diff_z;
        }
        return diff_z <= Config.MAX_Z_DIFF;
    }

    private static Location MoveCheck(int _x, int _y, int _z, int _tx, int _ty, boolean withCollision, boolean backwardMove, boolean returnPrev, int geoIndex) {
        int el;
        int es;
        byte pdy;
        byte pdx;
        boolean overRegionEdge;
        int diff_x = _tx - _x;
        int diff_y = _ty - _y;
        byte incx = GeoEngine.sign(diff_x);
        byte incy = GeoEngine.sign(diff_y);
        boolean bl = overRegionEdge = _x >> 11 != _tx >> 11 || _y >> 11 != _ty >> 11;
        if (diff_x < 0) {
            diff_x = -diff_x;
        }
        if (diff_y < 0) {
            diff_y = -diff_y;
        }
        if (diff_x > diff_y) {
            pdx = incx;
            pdy = 0;
            es = diff_y;
            el = diff_x;
        } else {
            pdx = 0;
            pdy = incy;
            es = diff_x;
            el = diff_y;
        }
        int err = el / 2;
        int curr_x = _x;
        int curr_y = _y;
        int curr_z = _z;
        int next_x = curr_x;
        int next_y = curr_y;
        int next_z = curr_z;
        int prev_x = curr_x;
        int prev_y = curr_y;
        int prev_z = curr_z;
        short[] next_layers = new short[MAX_LAYERS + 1];
        short[] temp_layers = new short[MAX_LAYERS + 1];
        short[] curr_layers = new short[MAX_LAYERS + 1];
        GeoEngine.NGetLayers(curr_x, curr_y, curr_layers, geoIndex);
        for (int i = 0; i < el; ++i) {
            if ((err -= es) < 0) {
                err += el;
                next_x += incx;
                next_y += incy;
            } else {
                next_x += pdx;
                next_y += pdy;
            }
            boolean regionEdge = overRegionEdge && (next_x >> 11 != curr_x >> 11 || next_y >> 11 != curr_y >> 11);
            GeoEngine.NGetLayers(next_x, next_y, next_layers, geoIndex);
            next_z = GeoEngine.NcanMoveNext(curr_x, curr_y, curr_z, curr_layers, next_x, next_y, next_layers, temp_layers, withCollision, regionEdge, geoIndex);
            if (next_z == Integer.MIN_VALUE || backwardMove && GeoEngine.NcanMoveNext(next_x, next_y, next_z, next_layers, curr_x, curr_y, curr_layers, temp_layers, withCollision, regionEdge, geoIndex) == Integer.MIN_VALUE) break;
            short[] t = curr_layers;
            curr_layers = next_layers;
            next_layers = t;
            if (returnPrev) {
                prev_x = curr_x;
                prev_y = curr_y;
                prev_z = curr_z;
            }
            curr_x = next_x;
            curr_y = next_y;
            curr_z = next_z;
        }
        if (returnPrev) {
            curr_x = prev_x;
            curr_y = prev_y;
            curr_z = prev_z;
        }
        return new Location(curr_x, curr_y, curr_z);
    }

    public static List<Location> MoveList(int __x, int __y, int _z, int __tx, int __ty, int geoIndex, boolean onlyFullPath) {
        int el;
        int es;
        byte pdy;
        byte pdx;
        boolean overRegionEdge;
        int _x = GeoEngine.getGeoX(__x);
        int _y = GeoEngine.getGeoY(__y);
        int _tx = GeoEngine.getGeoX(__tx);
        int _ty = GeoEngine.getGeoY(__ty);
        int diff_x = _tx - _x;
        int diff_y = _ty - _y;
        byte incx = GeoEngine.sign(diff_x);
        byte incy = GeoEngine.sign(diff_y);
        boolean bl = overRegionEdge = _x >> 11 != _tx >> 11 || _y >> 11 != _ty >> 11;
        if (diff_x < 0) {
            diff_x = -diff_x;
        }
        if (diff_y < 0) {
            diff_y = -diff_y;
        }
        if (diff_x > diff_y) {
            pdx = incx;
            pdy = 0;
            es = diff_y;
            el = diff_x;
        } else {
            pdx = 0;
            pdy = incy;
            es = diff_x;
            el = diff_y;
        }
        int err = el / 2;
        int curr_x = _x;
        int curr_y = _y;
        int curr_z = _z;
        int next_x = curr_x;
        int next_y = curr_y;
        int next_z = curr_z;
        short[] next_layers = new short[MAX_LAYERS + 1];
        short[] temp_layers = new short[MAX_LAYERS + 1];
        short[] curr_layers = new short[MAX_LAYERS + 1];
        GeoEngine.NGetLayers(curr_x, curr_y, curr_layers, geoIndex);
        if (curr_layers[0] == 0) {
            return null;
        }
        ArrayList<Location> result = new ArrayList<Location>(el + 1);
        result.add(new Location(curr_x, curr_y, curr_z));
        for (int i = 0; i < el; ++i) {
            if ((err -= es) < 0) {
                err += el;
                next_x += incx;
                next_y += incy;
            } else {
                next_x += pdx;
                next_y += pdy;
            }
            boolean regionEdge = overRegionEdge && (next_x >> 11 != curr_x >> 11 || next_y >> 11 != curr_y >> 11);
            GeoEngine.NGetLayers(next_x, next_y, next_layers, geoIndex);
            next_z = GeoEngine.NcanMoveNext(curr_x, curr_y, curr_z, curr_layers, next_x, next_y, next_layers, temp_layers, false, regionEdge, geoIndex);
            if (next_z == Integer.MIN_VALUE) {
                if (!onlyFullPath) break;
                return null;
            }
            short[] t = curr_layers;
            curr_layers = next_layers;
            next_layers = t;
            curr_x = next_x;
            curr_y = next_y;
            curr_z = next_z;
            result.add(new Location(curr_x, curr_y, curr_z));
        }
        return result;
    }

    private static Location MoveCheckForAI(int x, int y, int z, int tx, int ty, int geoIndex) {
        int dx = tx - x;
        int dy = ty - y;
        byte inc_x = GeoEngine.sign(dx);
        byte inc_y = GeoEngine.sign(dy);
        if ((dx = Math.abs(dx)) + (dy = Math.abs(dy)) < 2 || dx == 2 && dy == 0 || dx == 0 && dy == 2) {
            return new Location(x, y, z);
        }
        int prev_x = x;
        int prev_y = y;
        int prev_z = z;
        int next_x = x;
        int next_y = y;
        int next_z = z;
        if (dx >= dy) {
            int delta_A = 2 * dy;
            int d = delta_A - dx;
            int delta_B = delta_A - 2 * dx;
            for (int i = 0; i < dx; ++i) {
                prev_x = x;
                prev_y = y;
                prev_z = z;
                x = next_x;
                y = next_y;
                z = next_z;
                if (d > 0) {
                    d += delta_B;
                    next_x += inc_x;
                    next_y += inc_y;
                } else {
                    d += delta_A;
                    next_x += inc_x;
                }
                next_z = GeoEngine.NcanMoveNextForAI(x, y, z, next_x, next_y, geoIndex);
                if (next_z != 0) continue;
                return new Location(prev_x, prev_y, prev_z);
            }
        } else {
            int delta_A = 2 * dx;
            int d = delta_A - dy;
            int delta_B = delta_A - 2 * dy;
            for (int i = 0; i < dy; ++i) {
                prev_x = x;
                prev_y = y;
                prev_z = z;
                x = next_x;
                y = next_y;
                z = next_z;
                if (d > 0) {
                    d += delta_B;
                    next_x += inc_x;
                    next_y += inc_y;
                } else {
                    d += delta_A;
                    next_y += inc_y;
                }
                next_z = GeoEngine.NcanMoveNextForAI(x, y, z, next_x, next_y, geoIndex);
                if (next_z != 0) continue;
                return new Location(prev_x, prev_y, prev_z);
            }
        }
        return new Location(next_x, next_y, next_z);
    }

    private static boolean NcanMoveNextExCheck(int x, int y, int h, int nextx, int nexty, int hexth, short[] temp_layers, boolean regionEdge, int geoIndex) {
        int maxDeltaZ;
        GeoEngine.NGetLayers(x, y, temp_layers, geoIndex);
        if (temp_layers[0] == 0) {
            return true;
        }
        short temp_layer = GeoEngine.FindNearestLowerLayer(temp_layers, h + Config.MIN_LAYER_HEIGHT, regionEdge);
        if (temp_layer == Short.MIN_VALUE) {
            return false;
        }
        short temp_layer_h = (short)((short)(temp_layer & 0xFFF0) >> 1);
        int n = maxDeltaZ = regionEdge ? Config.REGION_EDGE_MAX_Z_DIFF : Config.MAX_Z_DIFF;
        if (Math.abs(temp_layer_h - hexth) >= maxDeltaZ || Math.abs(temp_layer_h - h) >= maxDeltaZ) {
            return false;
        }
        return GeoEngine.checkNSWE((byte)(temp_layer & 0xF), x, y, nextx, nexty);
    }

    public static int NcanMoveNext(int x, int y, int z, short[] layers, int next_x, int next_y, short[] next_layers, short[] temp_layers, boolean withCollision, boolean regionEdge, int geoIndex) {
        if (layers[0] == 0 || next_layers[0] == 0) {
            return z;
        }
        short layer = GeoEngine.FindNearestLowerLayer(layers, z + Config.MIN_LAYER_HEIGHT, regionEdge);
        if (layer == Short.MIN_VALUE) {
            return Integer.MIN_VALUE;
        }
        byte layer_nswe = (byte)(layer & 0xF);
        if (!GeoEngine.checkNSWE(layer_nswe, x, y, next_x, next_y)) {
            return Integer.MIN_VALUE;
        }
        short layer_h = (short)((short)(layer & 0xFFF0) >> 1);
        short next_layer = GeoEngine.FindNearestLowerLayer(next_layers, layer_h + Config.MIN_LAYER_HEIGHT, regionEdge);
        if (next_layer == Short.MIN_VALUE) {
            return Integer.MIN_VALUE;
        }
        short next_layer_h = (short)((short)(next_layer & 0xFFF0) >> 1);
        if (x == next_x || y == next_y) {
            if (withCollision) {
                if (x == next_x) {
                    GeoEngine.NgetLowerHeightAndNSWE(x - 1, y, layer_h, temp_layers, geoIndex);
                    if (Math.abs(temp_layers[0] - layer_h) > 15 || !GeoEngine.checkNSWE(layer_nswe, x - 1, y, x, y) || !GeoEngine.checkNSWE((byte)temp_layers[1], x - 1, y, x - 1, next_y)) {
                        return Integer.MIN_VALUE;
                    }
                    GeoEngine.NgetLowerHeightAndNSWE(x + 1, y, layer_h, temp_layers, geoIndex);
                    if (Math.abs(temp_layers[0] - layer_h) > 15 || !GeoEngine.checkNSWE(layer_nswe, x + 1, y, x, y) || !GeoEngine.checkNSWE((byte)temp_layers[1], x + 1, y, x + 1, next_y)) {
                        return Integer.MIN_VALUE;
                    }
                    return next_layer_h;
                }
                int maxDeltaZ = regionEdge ? Config.REGION_EDGE_MAX_Z_DIFF : Config.MAX_Z_DIFF;
                GeoEngine.NgetLowerHeightAndNSWE(x, y - 1, layer_h, temp_layers, geoIndex);
                if (Math.abs(temp_layers[0] - layer_h) >= maxDeltaZ || !GeoEngine.checkNSWE(layer_nswe, x, y - 1, x, y) || !GeoEngine.checkNSWE((byte)temp_layers[1], x, y - 1, next_x, y - 1)) {
                    return Integer.MIN_VALUE;
                }
                GeoEngine.NgetLowerHeightAndNSWE(x, y + 1, layer_h, temp_layers, geoIndex);
                if (Math.abs(temp_layers[0] - layer_h) >= maxDeltaZ || !GeoEngine.checkNSWE(layer_nswe, x, y + 1, x, y) || !GeoEngine.checkNSWE((byte)temp_layers[1], x, y + 1, next_x, y + 1)) {
                    return Integer.MIN_VALUE;
                }
            }
            return next_layer_h;
        }
        if (!GeoEngine.NcanMoveNextExCheck(x, next_y, layer_h, next_x, next_y, next_layer_h, temp_layers, regionEdge, geoIndex)) {
            return Integer.MIN_VALUE;
        }
        if (!GeoEngine.NcanMoveNextExCheck(next_x, y, layer_h, next_x, next_y, next_layer_h, temp_layers, regionEdge, geoIndex)) {
            return Integer.MIN_VALUE;
        }
        // Anti-corner-cut: verify adjacent cells allow diagonal passage
        int dirNswe = (next_x > x ? EAST : WEST) | (next_y > y ? SOUTH : NORTH);
        if (!GeoEngine.checkNearestNsweAntiCornerCut(x, y, layer_h, dirNswe, geoIndex)) {
            return Integer.MIN_VALUE;
        }
        return next_layer_h;
    }

    public static int NcanMoveNextForAI(int x, int y, int z, int next_x, int next_y, int geoIndex) {
        short h;
        short[] layers1 = new short[MAX_LAYERS + 1];
        short[] layers2 = new short[MAX_LAYERS + 1];
        GeoEngine.NGetLayers(x, y, layers1, geoIndex);
        GeoEngine.NGetLayers(next_x, next_y, layers2, geoIndex);
        if (layers1[0] == 0 || layers2[0] == 0) {
            return z == 0 ? 1 : z;
        }
        int z1 = Short.MIN_VALUE;
        byte NSWE1 = 15;
        for (int i = 1; i <= layers1[0]; ++i) {
            h = (short)((short)(layers1[i] & 0xFFF0) >> 1);
            if (Math.abs(z - z1) <= Math.abs(z - h)) continue;
            z1 = h;
            NSWE1 = (byte)(layers1[i] & 0xF);
        }
        if (z1 == Short.MIN_VALUE) {
            return 0;
        }
        int z2 = Short.MIN_VALUE;
        byte NSWE2 = 15;
        for (int i = 1; i <= layers2[0]; ++i) {
            h = (short)((short)(layers2[i] & 0xFFF0) >> 1);
            if (Math.abs(z - z2) <= Math.abs(z - h)) continue;
            z2 = h;
            NSWE2 = (byte)(layers2[i] & 0xF);
        }
        if (z2 == Short.MIN_VALUE) {
            return 0;
        }
        if (z1 > z2 && z1 - z2 > Config.MAX_Z_DIFF) {
            return 0;
        }
        if (!GeoEngine.checkNSWE(NSWE1, x, y, next_x, next_y) || !GeoEngine.checkNSWE(NSWE2, next_x, next_y, x, y)) {
            return 0;
        }
        return z2 == 0 ? 1 : z2;
    }

    public static void NGetLayers(int geoX, int geoY, short[] result, int geoIndex) {
        result[0] = 0;
        byte[] block = GeoEngine.getGeoBlockFromGeoCoords(geoX, geoY, geoIndex, false);
        if (block == null) {
            return;
        }
        int index = 0;
        byte type = block[index];
        ++index;
        switch (type) {
            case 0: {
                short height = GeoEngine.makeShort(block[index + 1], block[index]);
                height = (short)(height & 0xFFF0);
                result[0] = (short)(result[0] + 1);
                result[1] = (short)((short)(height << 1) | 0xF);
                return;
            }
            case 1: {
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                short height = GeoEngine.makeShort(block[(index += (cellX << 3) + cellY << 1) + 1], block[index]);
                result[0] = (short)(result[0] + 1);
                result[1] = height;
                return;
            }
            case 2: {
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                for (int offset = (cellX << 3) + cellY; offset > 0; --offset) {
                    byte lc = block[index];
                    index += (lc << 1) + 1;
                }
                byte layer_count = block[index];
                ++index;
                if (layer_count <= 0 || layer_count > MAX_LAYERS) {
                    return;
                }
                result[0] = layer_count;
                while (layer_count > 0) {
                    result[layer_count] = GeoEngine.makeShort(block[index + 1], block[index]);
                    layer_count = (byte)(layer_count - 1);
                    index += 2;
                }
                return;
            }
        }
        _log.error("GeoEngine: Unknown block type");
    }

    private static short NgetType(int geoX, int geoY, int geoIndex) {
        byte[] block = GeoEngine.getGeoBlockFromGeoCoords(geoX, geoY, geoIndex, false);
        if (block == null) {
            return 0;
        }
        return block[0];
    }

    public static int NgetLowerHeight(int geoX, int geoY, short z, int geoIndex) {
        short[] result = new short[2];
        GeoEngine.NgetLowerHeightAndNSWE(geoX, geoY, z, result, geoIndex);
        return result[0];
    }

    public static byte NgetLowerNSWE(int geoX, int geoY, short z, int geoIndex) {
        short[] result = new short[2];
        GeoEngine.NgetLowerHeightAndNSWE(geoX, geoY, z, result, geoIndex);
        return (byte)result[1];
    }

    /**
     * Checks whether a specific direction flag is set in the NSWE at the given geo position.
     */
    private static boolean checkNsweAt(int geoX, int geoY, int worldZ, int directionFlag, int geoIndex) {
        byte nswe = GeoEngine.NgetLowerNSWE(geoX, geoY, (short)worldZ, geoIndex);
        return (nswe & directionFlag) != 0;
    }

    /**
     * Anti-corner-cut validation for diagonal movements.
     * For each diagonal direction in the given NSWE flags, verifies that BOTH adjacent
     * cardinal cells allow passage in their respective directions.
     * This prevents cutting corners through narrow gaps.
     *
     * @param geoX geo X coordinate
     * @param geoY geo Y coordinate
     * @param worldZ world Z coordinate
     * @param nswe combined NSWE direction flags to validate
     * @param geoIndex geodata index
     * @return true if movement is allowed (no corner-cutting detected)
     */
    public static boolean checkNearestNsweAntiCornerCut(int geoX, int geoY, int worldZ, int nswe, int geoIndex) {
        // NSWE constants: EAST=1, WEST=2, SOUTH=4, NORTH=8
        // Combined diagonals: NE=9, NW=10, SE=5, SW=6

        // Check North-East: cell to north must allow East, cell to east must allow North
        if ((nswe & 9) == 9) {
            if (!checkNsweAt(geoX, geoY - 1, worldZ, EAST, geoIndex)
                    || !checkNsweAt(geoX + 1, geoY, worldZ, NORTH, geoIndex)) {
                return false;
            }
        }

        // Check North-West: cell to north must allow West, cell to west must allow North
        if ((nswe & 10) == 10) {
            if (!checkNsweAt(geoX, geoY - 1, worldZ, WEST, geoIndex)
                    || !checkNsweAt(geoX - 1, geoY, worldZ, NORTH, geoIndex)) {
                return false;
            }
        }

        // Check South-East: cell to south must allow East, cell to east must allow South
        if ((nswe & 5) == 5) {
            if (!checkNsweAt(geoX, geoY + 1, worldZ, EAST, geoIndex)
                    || !checkNsweAt(geoX + 1, geoY, worldZ, SOUTH, geoIndex)) {
                return false;
            }
        }

        // Check South-West: cell to south must allow West, cell to west must allow South
        if ((nswe & 6) == 6) {
            if (!checkNsweAt(geoX, geoY + 1, worldZ, WEST, geoIndex)
                    || !checkNsweAt(geoX - 1, geoY, worldZ, SOUTH, geoIndex)) {
                return false;
            }
        }

        return true;
    }

    public static void NgetLowerHeightAndNSWE(int geoX, int geoY, short z, short[] result, int geoIndex) {
        byte[] block = GeoEngine.getGeoBlockFromGeoCoords(geoX, geoY, geoIndex, false);
        if (block == null) {
            result[0] = z;
            result[1] = 15;
            return;
        }
        int index = 0;
        int NSWE = 15;
        byte type = block[index];
        ++index;
        int z_nearest_lower_limit = Math.min(z + Config.MIN_LAYER_HEIGHT, Short.MAX_VALUE);
        switch (type) {
            case 0: {
                short layer = GeoEngine.makeShort(block[index + 1], block[index]);
                short height = (short)(layer & 0xFFF0);
                result[0] = height >= z_nearest_lower_limit ? (short)World.MAP_MIN_Z : height;
                result[1] = 15;
                return;
            }
            case 1: {
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                short layer = GeoEngine.makeShort(block[(index += (cellX << 3) + cellY << 1) + 1], block[index]);
                short height = (short)((short)(layer & 0xFFF0) >> 1);
                if (height >= z_nearest_lower_limit) {
                    result[0] = (short)World.MAP_MIN_Z;
                    result[1] = 15;
                } else {
                    result[0] = height;
                    result[1] = (short)(layer & 0xF);
                }
                return;
            }
            case 2: {
                int height;
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                for (int offset = (cellX << 3) + cellY; offset > 0; --offset) {
                    byte lc = block[index];
                    index += (lc << 1) + 1;
                }
                byte layers = block[index];
                ++index;
                if (layers <= 0 || layers > MAX_LAYERS) {
                    result[0] = z;
                    result[1] = 15;
                    return;
                }
                int tempz1 = Short.MIN_VALUE;
                int tempz2 = Short.MIN_VALUE;
                int index_nswe1 = 0;
                int index_nswe2 = 0;
                while (layers > 0) {
                    height = (short)((short)(GeoEngine.makeShort(block[index + 1], block[index]) & 0xFFF0) >> 1);
                    if (height < z_nearest_lower_limit) {
                        if (height > tempz1) {
                            tempz1 = height;
                            index_nswe1 = index;
                        }
                    } else if (Math.abs(z - height) < Math.abs(z - tempz2)) {
                        tempz2 = height;
                        index_nswe2 = index;
                    }
                    layers = (byte)(layers - 1);
                    index += 2;
                }
                if (index_nswe1 > 0) {
                    NSWE = GeoEngine.makeShort(block[index_nswe1 + 1], block[index_nswe1]);
                    NSWE = (short)(NSWE & 0xF);
                } else if (index_nswe2 > 0) {
                    NSWE = GeoEngine.makeShort(block[index_nswe2 + 1], block[index_nswe2]);
                    NSWE = (short)(NSWE & 0xF);
                }
                int n = height = tempz1 > Short.MIN_VALUE ? tempz1 : tempz2;
                if (height >= z_nearest_lower_limit) {
                    result[0] = (short)World.MAP_MIN_Z;
                    result[1] = 15;
                } else {
                    result[0] = (short)height;
                    result[1] = (short)NSWE;
                }
                return;
            }
        }
        _log.error("GeoEngine: Unknown block type.");
        result[0] = z;
        result[1] = 15;
    }

    public static int NgetUpperHeight(int geoX, int geoY, short z, int geoIndex) {
        short[] result = new short[2];
        GeoEngine.NgetUpperHeightAndNSWE(geoX, geoY, z, result, geoIndex);
        return result[0];
    }

    public static byte NgetUpperNSWE(int geoX, int geoY, short z, int geoIndex) {
        short[] result = new short[2];
        GeoEngine.NgetUpperHeightAndNSWE(geoX, geoY, z, result, geoIndex);
        return (byte)result[1];
    }

    public static void NgetUpperHeightAndNSWE(int geoX, int geoY, short z, short[] result, int geoIndex) {
        byte[] block = GeoEngine.getGeoBlockFromGeoCoords(geoX, geoY, geoIndex, false);
        if (block == null) {
            result[0] = z;
            result[1] = 15;
            return;
        }
        int index = 0;
        int NSWE = 15;
        byte type = block[index];
        ++index;
        int z_nearest_lower_limit = Math.min(z + Config.MIN_LAYER_HEIGHT, Short.MAX_VALUE);
        switch (type) {
            case 0: {
                short layer = GeoEngine.makeShort(block[index + 1], block[index]);
                short height = (short)(layer & 0xFFF0);
                result[0] = height < z_nearest_lower_limit ? (short)World.MAP_MAX_Z : height;
                result[1] = 15;
                return;
            }
            case 1: {
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                short layer = GeoEngine.makeShort(block[(index += (cellX << 3) + cellY << 1) + 1], block[index]);
                short height = (short)((short)(layer & 0xFFF0) >> 1);
                if (height < z_nearest_lower_limit) {
                    result[0] = (short)World.MAP_MAX_Z;
                    result[1] = 15;
                } else {
                    result[0] = height;
                    result[1] = (short)(layer & 0xF);
                }
                return;
            }
            case 2: {
                int height;
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                for (int offset = (cellX << 3) + cellY; offset > 0; --offset) {
                    byte lc = block[index];
                    index += (lc << 1) + 1;
                }
                byte layers = block[index];
                ++index;
                if (layers <= 0 || layers > MAX_LAYERS) {
                    result[0] = z;
                    result[1] = 15;
                    return;
                }
                int tempz1 = Short.MAX_VALUE;
                int tempz2 = Short.MAX_VALUE;
                int index_nswe1 = 0;
                int index_nswe2 = 0;
                while (layers > 0) {
                    height = (short)((short)(GeoEngine.makeShort(block[index + 1], block[index]) & 0xFFF0) >> 1);
                    if (height >= z_nearest_lower_limit) {
                        if (height < tempz1) {
                            tempz1 = height;
                            index_nswe1 = index;
                        }
                    } else if (Math.abs(z - height) > Math.abs(z - tempz2)) {
                        tempz2 = height;
                        index_nswe2 = index;
                    }
                    layers = (byte)(layers - 1);
                    index += 2;
                }
                if (index_nswe1 > 0) {
                    NSWE = GeoEngine.makeShort(block[index_nswe1 + 1], block[index_nswe1]);
                    NSWE = (short)(NSWE & 0xF);
                } else if (index_nswe2 > 0) {
                    NSWE = GeoEngine.makeShort(block[index_nswe2 + 1], block[index_nswe2]);
                    NSWE = (short)(NSWE & 0xF);
                }
                int n = height = tempz1 < Short.MAX_VALUE ? tempz1 : tempz2;
                if (height < z_nearest_lower_limit) {
                    result[0] = (short)World.MAP_MAX_Z;
                    result[1] = 15;
                } else {
                    result[0] = (short)height;
                    result[1] = (short)NSWE;
                }
                return;
            }
        }
        _log.error("GeoEngine: Unknown block type.");
        result[0] = z;
        result[1] = 15;
    }

    protected static short makeShort(byte b1, byte b0) {
        return (short)(b1 << 8 | b0 & 0xFF);
    }

    protected static int getBlock(int geoPos) {
        return (geoPos >> 3) % 256;
    }

    protected static int getCell(int geoPos) {
        return geoPos % 8;
    }

    protected static int getBlockIndex(int blockX, int blockY) {
        return (blockX << 8) + blockY;
    }

    private static byte sign(int x) {
        if (x >= 0) {
            return 1;
        }
        return -1;
    }

    
    private static byte[] getGeoBlockFromGeoCoords(int geoX, int geoY, int geoIndex, boolean loadIfNotExists) {
        if (!Config.ALLOW_GEODATA) {
            return null;
        }
        int ix = geoX >> 11;
        int iy = geoY >> 11;
        if (ix < 0 || ix >= World.WORLD_SIZE_X || iy < 0 || iy >= World.WORLD_SIZE_Y) {
            return null;
        }
        if (loadIfNotExists) {
            _geoWriteLock.lock();
            try {
                byte[][][][] geodataByRegion = geodata[geoIndex];
                if (geodataByRegion == null) {
                    return null;
                }
                byte[][] region = geodataByRegion[ix][iy];
                if (region == null) {
                    if (geoIndex > 0) {
                        region = geodata[0][ix][iy];
                        if (region == null) {
                            return null;
                        }
                        byte[][] newRegion = new byte[region.length][];
                        for (int i = 0; i < region.length; ++i) {
                            newRegion[i] = (byte[])region[i].clone();
                        }
                        GeoEngine.geodata[geoIndex][ix][iy] = newRegion;
                        region = newRegion;
                    } else {
                        return null;
                    }
                }
                return region[GeoEngine.getBlockIndex(GeoEngine.getBlock(geoX), GeoEngine.getBlock(geoY))];
            } finally {
                _geoWriteLock.unlock();
            }
        }
        byte[][][][] geodataByRegion = geodata[geoIndex];
        if (geodataByRegion == null) {
            return null;
        }
        byte[][] region = geodataByRegion[ix][iy];
        if (region == null) {
            if (geoIndex > 0) {
                region = geodata[0][ix][iy];
                if (region == null) {
                    return null;
                }
            } else {
                return null;
            }
        }
        return region[GeoEngine.getBlockIndex(GeoEngine.getBlock(geoX), GeoEngine.getBlock(geoY))];
    }

    public static void load() {
        if (!Config.ALLOW_GEODATA) {
            _log.info("GeoEngine: Disabled.");
            return;
        }
        _log.info("GeoEngine: Loading Geodata...");
        File geoDir = new File(Config.GEODATA_ROOT, "");
        if (!geoDir.exists() || !geoDir.isDirectory()) {
            throw new RuntimeException("GeoEngine: Files missing, loading aborted.");
        }
        int count = 0;
        for (int rx = Config.GEO_X_FIRST; rx <= Config.GEO_X_LAST; ++rx) {
            for (int ry = Config.GEO_Y_FIRST; ry <= Config.GEO_Y_LAST; ++ry) {
                int blobOff;
                File geoFile = new File(geoDir, String.format("%2d_%2d" + L2S_EXTENSION, rx, ry));
                if (geoFile.exists()) {
                    blobOff = 4;
                } else {
                    geoFile = new File(geoDir, String.format("%2d_%2d" + L2J_EXTENSION, rx, ry));
                    if (!geoFile.exists()) continue;
                    blobOff = 0;
                }
                GeoEngine.LoadGeodataFile(rx, ry, geoFile, blobOff);
                ++count;
            }
        }
        if (count == 0) {
            throw new RuntimeException("GeoEngine: Files missing, loading aborted.");
        }
        _log.info("GeoEngine: Loaded " + count + " map(s), max layers: " + MAX_LAYERS);
        if (Config.COMPACT_GEO) {
            GeoEngine.compact();
        }
    }

    public static boolean LoadGeodataFile(int rx, int ry, File geoFile) {
        return GeoEngine.LoadGeodataFile(rx, ry, geoFile, 0);
    }

    public static boolean LoadGeodataFile(int rx, int ry, File geoFile, int blobOff) {
        ByteBuffer buff;
        int ix = rx - Config.GEO_X_FIRST;
        int iy = ry - Config.GEO_Y_FIRST;
        _log.debug("GeoEngine: Loading: " + geoFile.getName());
        try {
            FileChannel roChannel = new RandomAccessFile(geoFile, "r").getChannel();
            int size = (int)roChannel.size() - blobOff;
            buff = ByteBuffer.allocate(size);
            if (blobOff > 0) {
                buff.limit(blobOff);
            }
            buff.order(ByteOrder.LITTLE_ENDIAN);
            roChannel.read(buff);
            buff.rewind();
            int checkSum = GeoCrypt.decrypt(blobOff, roChannel, buff);
            if (checkSum != 0 || size < 196608) {
                throw new Error("Invalid geodata : " + geoFile.getName() + " with size " + size + " !");
            }
        }
        catch (IOException e) {
            throw new Error(e);
        }
        int index = 0;
        int block = 0;
        byte floor = 0;
        _geoWriteLock.lock();
        try {
            byte[][] blocks = geodata[0][ix][iy];
            if (blocks == null) {
                byte[][] byArrayArray = new byte[65536][];
                blocks = byArrayArray;
                GeoEngine.geodata[0][ix][iy] = byArrayArray;
            }
            block10: for (block = 0; block < 65536; ++block) {
                byte type = buff.get(index);
                ++index;
                switch (type) {
                    case 0: {
                        byte[] geoBlock = new byte[]{type, buff.get(index), buff.get(index + 1)};
                        index += 2;
                        blocks[block] = geoBlock;
                        continue block10;
                    }
                    case 1: {
                        byte[] geoBlock = new byte[129];
                        geoBlock[0] = type;
                        buff.position(index);
                        buff.get(geoBlock, 1, 128);
                        index += 128;
                        blocks[block] = geoBlock;
                        continue block10;
                    }
                    case 2: {
                        int orgIndex = index;
                        for (int b = 0; b < 64; ++b) {
                            byte layers = buff.get(index);
                            MAX_LAYERS = Math.max(MAX_LAYERS, layers);
                            index += (layers << 1) + 1;
                            if (layers <= floor) continue;
                            floor = layers;
                        }
                        int diff = index - orgIndex;
                        byte[] geoBlock = new byte[diff + 1];
                        geoBlock[0] = type;
                        buff.position(orgIndex);
                        buff.get(geoBlock, 1, diff);
                        blocks[block] = geoBlock;
                        continue block10;
                    }
                    default: {
                        throw new RuntimeException("Invalid geodata: " + rx + "_" + ry + "!");
                    }
                }
            }
            return true;
        } finally {
            _geoWriteLock.unlock();
        }
    }

    public static int createGeoIndex() {
        if (!Config.ALLOW_GEODATA) {
            return 0;
        }
        _geoWriteLock.lock();
        try {
            int geoIndex = -1;
            for (int i = 1; i < geodata.length; ++i) {
                if (geodata[i] != null) continue;
                geoIndex = i;
                break;
            }
            if (geoIndex == -1) {
                int oldSize;
                geoIndex = oldSize = geodata.length;
                byte[][][][][] resizedGeodata = new byte[geoIndex + 1000][][][][];
                for (int i = 0; i < oldSize; ++i) {
                    resizedGeodata[i] = geodata[i];
                }
                _log.info("Geodata indexes resized from " + oldSize + " to " + resizedGeodata.length);
                geodata = resizedGeodata;
            }
            GeoEngine.geodata[geoIndex] = new byte[World.WORLD_SIZE_X][World.WORLD_SIZE_Y][][];
            return geoIndex;
        } finally {
            _geoWriteLock.unlock();
        }
    }

    public static void deleteGeoIndex(int geoIndex) {
        if (!Config.ALLOW_GEODATA) {
            return;
        }
        if (geoIndex == 0) {
            return;
        }
        _geoWriteLock.lock();
        try {
            GeoEngine.geodata[geoIndex] = null;
        } finally {
            _geoWriteLock.unlock();
        }
    }

    private static void copyBlock(int geoX, int geoY, int geoIndex) {
        int ix = geoX >> 11;
        int iy = geoY >> 11;
        if (ix < 0 || ix >= World.WORLD_SIZE_X || iy < 0 || iy >= World.WORLD_SIZE_Y) {
            return;
        }
        byte[][] region = geodata[geoIndex][ix][iy];
        if (region == null) {
            return;
        }
        int blockIndex = GeoEngine.getBlockIndex(GeoEngine.getBlock(geoX), GeoEngine.getBlock(geoY));
        byte[] block = region[blockIndex];
        byte blockType = block[0];
        switch (blockType) {
            case 0: {
                short height = GeoEngine.makeShort(block[2], block[1]);
                height = (short)(height & 0xFFF0);
                height = (short)(height << 1);
                height = (short)(height | 8);
                height = (short)(height | 4);
                height = (short)(height | 2);
                height = (short)(height | 1);
                byte[] newblock = new byte[129];
                newblock[0] = 1;
                for (int i = 1; i < 129; i += 2) {
                    newblock[i + 1] = (byte)(height >> 8);
                    newblock[i] = (byte)(height & 0xFF);
                }
                region[blockIndex] = newblock;
            }
        }
    }

    private static boolean checkControlZ(int minZ, int maxZ, int geoZ) {
        return minZ <= geoZ && geoZ <= maxZ || Math.abs((minZ + maxZ) / 2 - geoZ) <= 256;
    }

    private static boolean checkCellInControl(int geoX, int geoY, Shape shape) {
        return shape.isOnPerimeter(geoX, geoY, WORLD_TO_GEO_COORD_CONVERTER) || shape.isInside(geoX, geoY, WORLD_TO_GEO_COORD_CONVERTER);
    }

    public static boolean returnGeoControl(GeoControl control) {
        if (!Config.ALLOW_GEODATA) {
            return false;
        }
        _geoWriteLock.lock();
        try {
            int geoIndex = control.getGeoControlIndex();
            if (geoIndex == 0) {
                _log.warn("GeoEngine: Attempt to return geo control with 0 geoControlIndex!");
                Thread.dumpStack();
                return false;
            }
            TIntObjectMap<ByteObjectPair<CeilGeoControlType>> around = control.getGeoAround();
            if (around == null) {
                _log.warn("GeoEngine: Attempt to return geo control without applyed geo control!");
                Thread.dumpStack();
                return false;
            }
            Shape shape = control.getGeoShape();
            boolean result = false;
            for (int geoXY : around.keys()) {
                int geoY;
                int geoX = GeoEngine.getGeoXFromHash(geoXY);
                byte[] block = GeoEngine.getGeoBlockFromGeoCoords(geoX, geoY = GeoEngine.getGeoYFromHash(geoXY), geoIndex, false);
                if (block == null) continue;
                Set<GeoControl> geoControls = null;
                int hashCode = 0;
                int ix = geoX >> 11;
                int iy = geoY >> 11;
                if (ix >= 0 && ix < World.WORLD_SIZE_X && iy >= 0 && iy < World.WORLD_SIZE_Y) {
                    hashCode = GeoEngine.makeRegionHashCode(ix, iy, geoIndex);
                    geoControls = (Set)_activeGeoControls.get(hashCode);
                }
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                int index = 0;
                byte blockType = block[index];
                ++index;
                boolean success = false;
                switch (blockType) {
                    case 1: {
                        short height = GeoEngine.makeShort(block[(index += (cellX << 3) + cellY << 1) + 1], block[index]);
                        int old_nswe = (byte)(height & 0xF);
                        height = (short)(height & 0xFFF0);
                        height = (short)(height >> 1);
                        ByteObjectPair aroundInfo = (ByteObjectPair)around.get(geoXY);
                        if (aroundInfo.getValue() == CeilGeoControlType.INSIDE) {
                            int defaultLowerHeight = GeoEngine.NgetLowerHeight(geoX, geoY, height, 0);
                            int defaultUpperHeight = GeoEngine.NgetUpperHeight(geoX, geoY, height, 0);
                            height = (short)defaultLowerHeight;
                            if (geoControls != null) {
                                for (GeoControl tempControl : geoControls) {
                                    ByteObjectPair tempAroundInfo;
                                    TIntObjectMap<ByteObjectPair<CeilGeoControlType>> tempGeoAround;
                                    Shape tempShape;
                                    if (tempControl == control || tempControl.getGeoControlIndex() != geoIndex || (tempShape = tempControl.getGeoShape()) == null || (tempGeoAround = tempControl.getGeoAround()) == null || (tempAroundInfo = (ByteObjectPair)tempGeoAround.get(geoXY)) == null || tempAroundInfo.getValue() != CeilGeoControlType.INSIDE || tempShape.getZmax() < defaultLowerHeight || tempShape.getZmin() > defaultLowerHeight) continue;
                                    height = (short)Math.max(height, Math.min(Math.min(defaultLowerHeight + 256, tempShape.getZmax()), defaultUpperHeight - Config.MIN_LAYER_HEIGHT));
                                }
                            }
                        }
                        height = (short)(height << 1);
                        height = (short)(height & 0xFFF0);
                        height = (short)(height | old_nswe);
                        height = (short)(height | aroundInfo.getKey());
                        block[index + 1] = (byte)(height >> 8);
                        block[index] = (byte)(height & 0xFF);
                        success = true;
                        break;
                    }
                    case 2: {
                        short height;
                        int neededIndex = -1;
                        for (int offset = (cellX << 3) + cellY; offset > 0; --offset) {
                            byte lc = block[index];
                            index += (lc << 1) + 1;
                        }
                        byte layers = block[index];
                        ++index;
                        if (layers <= 0 || layers > MAX_LAYERS) break;
                        short temph = Short.MIN_VALUE;
                        int old_nswe = 15;
                        while (layers > 0) {
                            int z_diff_curr;
                            height = GeoEngine.makeShort(block[index + 1], block[index]);
                            byte tmp_nswe = (byte)(height & 0xF);
                            height = (short)(height & 0xFFF0);
                            height = (short)(height >> 1);
                            int z_diff_last = Math.abs(shape.getZmin() - temph);
                            if (z_diff_last > (z_diff_curr = Math.abs(shape.getZmin() - height))) {
                                old_nswe = tmp_nswe;
                                temph = height;
                                neededIndex = index;
                            }
                            layers = (byte)(layers - 1);
                            index += 2;
                        }
                        ByteObjectPair aroundInfo = (ByteObjectPair)around.get(geoXY);
                        if (aroundInfo.getValue() == CeilGeoControlType.INSIDE) {
                            int defaultLowerHeight = GeoEngine.NgetLowerHeight(geoX, geoY, temph, 0);
                            int defaultUpperHeight = GeoEngine.NgetUpperHeight(geoX, geoY, temph, 0);
                            temph = (short)defaultLowerHeight;
                            if (geoControls != null) {
                                for (GeoControl tempControl : geoControls) {
                                    ByteObjectPair tempAroundInfo;
                                    TIntObjectMap<ByteObjectPair<CeilGeoControlType>> tempGeoAround;
                                    Shape tempShape;
                                    if (tempControl == control || tempControl.getGeoControlIndex() != geoIndex || (tempShape = tempControl.getGeoShape()) == null || (tempGeoAround = tempControl.getGeoAround()) == null || (tempAroundInfo = (ByteObjectPair)tempGeoAround.get(geoXY)) == null || tempAroundInfo.getValue() != CeilGeoControlType.INSIDE || tempShape.getZmax() < defaultLowerHeight || tempShape.getZmin() > defaultLowerHeight) continue;
                                    temph = (short)Math.max(temph, Math.min(Math.min(defaultLowerHeight + 256, tempShape.getZmax()), defaultUpperHeight - Config.MIN_LAYER_HEIGHT));
                                }
                            }
                        }
                        temph = (short)(temph << 1);
                        temph = (short)(temph & 0xFFF0);
                        temph = (short)(temph | old_nswe);
                        temph = (short)(temph | aroundInfo.getKey());
                        block[neededIndex + 1] = (byte)(temph >> 8);
                        block[neededIndex] = (byte)(temph & 0xFF);
                        success = true;
                    }
                }
                if (!success) continue;
                if (geoControls != null) {
                    geoControls.remove(control);
                    if (geoControls.isEmpty()) {
                        _activeGeoControls.remove(hashCode);
                        if (geoIndex != 0) {
                            GeoEngine.geodata[geoIndex][ix][iy] = null;
                        }
                    }
                }
                result = true;
            }
            return result;
        } finally {
            _geoWriteLock.unlock();
        }
    }

    public static boolean applyGeoControl(GeoControl control, int geoIndex) {
        if (!Config.ALLOW_GEODATA) {
            return false;
        }
        if (geoIndex == 0) {
            _log.warn("GeoEngine: Attempt to apply geo control with 0 geoIndex!");
            Thread.dumpStack();
            return false;
        }
        _geoWriteLock.lock();
        try {
            int[] around_keys;
            boolean first_time;
            Shape shape = control.getGeoShape();
            if (shape == null) {
                _log.warn("GeoEngine: no shape for geo control: " + control);
                return false;
            }
            TIntObjectMap<ByteObjectPair<CeilGeoControlType>> around = control.getGeoAround();
            boolean bl = first_time = around == null;
            if (around == null) {
                around = new TIntObjectHashMap();
                TIntHashSet around_blocks = new TIntHashSet();
                int minX = GeoEngine.getGeoX(shape.getXmin());
                int maxX = GeoEngine.getGeoX(shape.getXmax());
                int minY = GeoEngine.getGeoY(shape.getYmin());
                int maxY = GeoEngine.getGeoY(shape.getYmax());
                for (int tmpX = minX; tmpX <= maxX; ++tmpX) {
                    for (int tmpY = minY; tmpY <= maxY; ++tmpY) {
                        if (!GeoEngine.checkCellInControl(tmpX, tmpY, shape)) continue;
                        around_blocks.add(GeoEngine.getGeoXYHash(tmpX, tmpY));
                    }
                }
                for (int geoXY : around_blocks.toArray()) {
                    byte _nswe;
                    ByteObjectPair _aroundInfo;
                    if (!control.isHollowGeo()) {
                        around.put(geoXY, new ByteObjectPairImpl((byte)15, CeilGeoControlType.INSIDE));
                    }
                    int geoX = GeoEngine.getGeoXFromHash(geoXY);
                    int geoY = GeoEngine.getGeoYFromHash(geoXY);
                    int aroundN_geoXY = GeoEngine.getGeoXYHash(geoX, geoY - 1);
                    int aroundS_geoXY = GeoEngine.getGeoXYHash(geoX, geoY + 1);
                    int aroundW_geoXY = GeoEngine.getGeoXYHash(geoX - 1, geoY);
                    int aroundE_geoXY = GeoEngine.getGeoXYHash(geoX + 1, geoY);
                    if (!around_blocks.contains(aroundN_geoXY)) {
                        if (around.containsKey(aroundN_geoXY)) {
                            _aroundInfo = (ByteObjectPair)around.remove(aroundN_geoXY);
                            _nswe = _aroundInfo.getKey();
                        } else {
                            _nswe = 0;
                        }
                        _nswe = (byte)(_nswe | 4);
                        around.put(aroundN_geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                        if (control.isHollowGeo()) {
                            if (around.containsKey(geoXY)) {
                                _aroundInfo = (ByteObjectPair)around.remove(geoXY);
                                _nswe = _aroundInfo.getKey();
                            } else {
                                _nswe = 0;
                            }
                            _nswe = (byte)(_nswe | 8);
                            around.put(geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                        }
                    }
                    if (!around_blocks.contains(aroundS_geoXY)) {
                        if (around.containsKey(aroundS_geoXY)) {
                            _aroundInfo = (ByteObjectPair)around.remove(aroundS_geoXY);
                            _nswe = _aroundInfo.getKey();
                        } else {
                            _nswe = 0;
                        }
                        _nswe = (byte)(_nswe | 8);
                        around.put(aroundS_geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                        if (control.isHollowGeo()) {
                            if (around.containsKey(geoXY)) {
                                _aroundInfo = (ByteObjectPair)around.remove(geoXY);
                                _nswe = _aroundInfo.getKey();
                            } else {
                                _nswe = 0;
                            }
                            _nswe = (byte)(_nswe | 4);
                            around.put(geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                        }
                    }
                    if (!around_blocks.contains(aroundW_geoXY)) {
                        if (around.containsKey(aroundW_geoXY)) {
                            _aroundInfo = (ByteObjectPair)around.remove(aroundW_geoXY);
                            _nswe = _aroundInfo.getKey();
                        } else {
                            _nswe = 0;
                        }
                        _nswe = (byte)(_nswe | 1);
                        around.put(aroundW_geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                        if (control.isHollowGeo()) {
                            if (around.containsKey(geoXY)) {
                                _aroundInfo = (ByteObjectPair)around.remove(geoXY);
                                _nswe = _aroundInfo.getKey();
                            } else {
                                _nswe = 0;
                            }
                            _nswe = (byte)(_nswe | 2);
                            around.put(geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                        }
                    }
                    if (around_blocks.contains(aroundE_geoXY)) continue;
                    if (around.containsKey(aroundE_geoXY)) {
                        _aroundInfo = (ByteObjectPair)around.remove(aroundE_geoXY);
                        _nswe = _aroundInfo.getKey();
                    } else {
                        _nswe = 0;
                    }
                    _nswe = (byte)(_nswe | 2);
                    around.put(aroundE_geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                    if (!control.isHollowGeo()) continue;
                    if (around.containsKey(geoXY)) {
                        _aroundInfo = (ByteObjectPair)around.remove(geoXY);
                        _nswe = _aroundInfo.getKey();
                    } else {
                        _nswe = 0;
                    }
                    _nswe = (byte)(_nswe | 1);
                    around.put(geoXY, new ByteObjectPairImpl(_nswe, CeilGeoControlType.PERIMETER));
                }
                around_blocks.clear();
                control.setGeoAround((TIntObjectMap<ByteObjectPair<CeilGeoControlType>>)around);
            }
            boolean result = false;
            for (int geoXY : around_keys = around.keys()) {
                int geoY;
                int geoX = GeoEngine.getGeoXFromHash(geoXY);
                byte[] block = GeoEngine.getGeoBlockFromGeoCoords(geoX, geoY = GeoEngine.getGeoYFromHash(geoXY), geoIndex, true);
                if (block == null) continue;
                if (first_time) {
                    GeoEngine.copyBlock(geoX, geoY, geoIndex);
                }
                int cellX = GeoEngine.getCell(geoX);
                int cellY = GeoEngine.getCell(geoY);
                int index = 0;
                byte blockType = block[index];
                ++index;
                boolean success = false;
                switch (blockType) {
                    case 1: {
                        byte close_nswe;
                        short height = GeoEngine.makeShort(block[(index += (cellX << 3) + cellY << 1) + 1], block[index]);
                        int old_nswe = (byte)(height & 0xF);
                        height = (short)(height & 0xFFF0);
                        height = (short)(height >> 1);
                        ByteObjectPair aroundInfo = (ByteObjectPair)around.get(geoXY);
                        if (aroundInfo.getValue() == CeilGeoControlType.INSIDE) {
                            int defaultLowerHeight = GeoEngine.NgetLowerHeight(geoX, geoY, height, 0);
                            int defaultUpperHeight = GeoEngine.NgetUpperHeight(geoX, geoY, height, 0);
                            height = (short)Math.max(height, Math.min(Math.min(defaultLowerHeight + 256, shape.getZmax()), defaultUpperHeight - Config.MIN_LAYER_HEIGHT));
                            around.put(geoXY, new ByteObjectPairImpl((byte)0, CeilGeoControlType.INSIDE));
                            height = (short)(height << 1);
                            height = (short)(height & 0xFFF0);
                            height = (short)(height | old_nswe);
                        } else {
                            if (aroundInfo.getValue() != CeilGeoControlType.PERIMETER) break;
                            if (first_time) {
                                around.remove(geoXY);
                                close_nswe = aroundInfo.getKey();
                                if (!GeoEngine.checkControlZ(shape.getZmin(), shape.getZmax(), height)) break;
                                close_nswe = (byte)(close_nswe & old_nswe);
                                around.put(geoXY, new ByteObjectPairImpl(close_nswe, CeilGeoControlType.PERIMETER));
                            } else {
                                close_nswe = aroundInfo.getKey();
                            }
                            height = (short)(height << 1);
                            height = (short)(height & 0xFFF0);
                            height = (short)(height | old_nswe);
                            height = (short)(height & ~close_nswe);
                        }
                        block[index + 1] = (byte)(height >> 8);
                        block[index] = (byte)(height & 0xFF);
                        success = true;
                        break;
                    }
                    case 2: {
                        byte close_nswe;
                        short height;
                        int neededIndex = -1;
                        for (int offset = (cellX << 3) + cellY; offset > 0; --offset) {
                            byte lc = block[index];
                            index += (lc << 1) + 1;
                        }
                        byte layers = block[index];
                        ++index;
                        if (layers <= 0 || layers > MAX_LAYERS) break;
                        short temph = Short.MIN_VALUE;
                        int old_nswe = 15;
                        while (layers > 0) {
                            int z_diff_curr;
                            height = GeoEngine.makeShort(block[index + 1], block[index]);
                            byte tmp_nswe = (byte)(height & 0xF);
                            height = (short)(height & 0xFFF0);
                            height = (short)(height >> 1);
                            int z_diff_last = Math.abs(shape.getZmin() - temph);
                            if (z_diff_last > (z_diff_curr = Math.abs(shape.getZmin() - height))) {
                                old_nswe = tmp_nswe;
                                temph = height;
                                neededIndex = index;
                            }
                            layers = (byte)(layers - 1);
                            index += 2;
                        }
                        ByteObjectPair aroundInfo = (ByteObjectPair)around.get(geoXY);
                        if (aroundInfo.getValue() == CeilGeoControlType.INSIDE) {
                            int defaultLowerHeight = GeoEngine.NgetLowerHeight(geoX, geoY, temph, 0);
                            int defaultUpperHeight = GeoEngine.NgetUpperHeight(geoX, geoY, temph, 0);
                            temph = (short)Math.max(temph, Math.min(Math.min(defaultLowerHeight + 256, shape.getZmax()), defaultUpperHeight - Config.MIN_LAYER_HEIGHT));
                            around.put(geoXY, new ByteObjectPairImpl((byte)0, CeilGeoControlType.INSIDE));
                            temph = (short)(temph << 1);
                            temph = (short)(temph & 0xFFF0);
                            temph = (short)(temph | old_nswe);
                        } else {
                            if (aroundInfo.getValue() != CeilGeoControlType.PERIMETER) break;
                            if (first_time) {
                                around.remove(geoXY);
                                close_nswe = aroundInfo.getKey();
                                if (temph == Short.MIN_VALUE || !GeoEngine.checkControlZ(shape.getZmin(), shape.getZmax(), temph)) break;
                                close_nswe = (byte)(close_nswe & old_nswe);
                                around.put(geoXY, new ByteObjectPairImpl(close_nswe, aroundInfo.getValue()));
                            } else {
                                close_nswe = aroundInfo.getKey();
                            }
                            temph = (short)(temph << 1);
                            temph = (short)(temph & 0xFFF0);
                            temph = (short)(temph | old_nswe);
                            temph = (short)(temph & ~close_nswe);
                        }
                        block[neededIndex + 1] = (byte)(temph >> 8);
                        block[neededIndex] = (byte)(temph & 0xFF);
                        success = true;
                    }
                }
                if (!success) continue;
                int ix = geoX >> 11;
                int iy = geoY >> 11;
                if (ix >= 0 && ix < World.WORLD_SIZE_X && iy >= 0 && iy < World.WORLD_SIZE_Y) {
                    int hashCode = GeoEngine.makeRegionHashCode(ix, iy, geoIndex);
                    CopyOnWriteArraySet<GeoControl> geoControls = (CopyOnWriteArraySet<GeoControl>)_activeGeoControls.get(hashCode);
                    if (geoControls == null) {
                        geoControls = new CopyOnWriteArraySet<GeoControl>();
                        _activeGeoControls.put(hashCode, geoControls);
                    }
                    geoControls.add(control);
                }
                result = true;
            }
            return result;
        } finally {
            _geoWriteLock.unlock();
        }
    }

    private static int makeRegionHashCode(int x, int y, int index) {
        return (x * 100 + y) * 100000 + index;
    }

    public static void compact() {
        long total = 0L;
        long optimized = 0L;
        for (int mapX = 0; mapX < World.WORLD_SIZE_X; ++mapX) {
            for (int mapY = 0; mapY < World.WORLD_SIZE_Y; ++mapY) {
                if (geodata[0][mapX][mapY] == null) continue;
                total += 65536L;
                GeoOptimizer.BlockLink[] links = GeoOptimizer.loadBlockMatches("geodata/matches/" + (mapX + Config.GEO_X_FIRST) + "_" + (mapY + Config.GEO_Y_FIRST) + ".matches");
                if (links == null) continue;
                for (int i = 0; i < links.length; ++i) {
                    byte[][] link_region = geodata[0][links[i].linkMapX][links[i].linkMapY];
                    if (link_region == null) continue;
                    link_region[links[i].linkBlockIndex] = geodata[0][mapX][mapY][links[i].blockIndex];
                    ++optimized;
                }
            }
        }
        _log.info(String.format("GeoEngine: - Compacted %d of %d blocks...", optimized, total));
    }

    public static boolean equalsData(byte[] a1, byte[] a2) {
        if (a1.length != a2.length) {
            return false;
        }
        for (int i = 0; i < a1.length; ++i) {
            if (a1[i] == a2[i]) continue;
            return false;
        }
        return true;
    }

    public static boolean compareGeoBlocks(int mapX1, int mapY1, int blockIndex1, int mapX2, int mapY2, int blockIndex2) {
        return GeoEngine.equalsData(geodata[0][mapX1][mapY1][blockIndex1], geodata[0][mapX2][mapY2][blockIndex2]);
    }

    private static void initChecksums() {
        _log.info("GeoEngine: - Generating Checksums...");
        new File(Config.GEODATA_ROOT, "checksum").mkdirs();
        ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
        GeoOptimizer.checkSums = new int[World.WORLD_SIZE_X][World.WORLD_SIZE_Y][];
        for (int mapX = 0; mapX < World.WORLD_SIZE_X; ++mapX) {
            for (int mapY = 0; mapY < World.WORLD_SIZE_Y; ++mapY) {
                if (geodata[0][mapX][mapY] == null) continue;
                executor.execute(new GeoOptimizer.CheckSumLoader(mapX, mapY, geodata[0][mapX][mapY]));
            }
        }
        try {
            executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
        }
        catch (InterruptedException e) {
            _log.error("", (Throwable)e);
        }
    }

    private static void initBlockMatches(int maxScanRegions) {
        _log.info("GeoEngine: Generating Block Matches...");
        new File(Config.GEODATA_ROOT, "matches").mkdirs();
        ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
        for (int mapX = 0; mapX < World.WORLD_SIZE_X; ++mapX) {
            for (int mapY = 0; mapY < World.WORLD_SIZE_Y; ++mapY) {
                if (geodata[0][mapX][mapY] == null || GeoOptimizer.checkSums == null || GeoOptimizer.checkSums[mapX][mapY] == null) continue;
                executor.execute(new GeoOptimizer.GeoBlocksMatchFinder(mapX, mapY, maxScanRegions));
            }
        }
        try {
            executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
        }
        catch (InterruptedException e) {
            _log.error("", (Throwable)e);
        }
    }

    public static void deleteChecksumFiles() {
        for (int mapX = 0; mapX < World.WORLD_SIZE_X; ++mapX) {
            for (int mapY = 0; mapY < World.WORLD_SIZE_Y; ++mapY) {
                if (geodata[0][mapX][mapY] == null) continue;
                new File(Config.GEODATA_ROOT, "checksum/" + (mapX + Config.GEO_X_FIRST) + "_" + (mapY + Config.GEO_Y_FIRST) + ".crc").delete();
            }
        }
    }

    public static void genBlockMatches(int maxScanRegions) {
        GeoEngine.initChecksums();
        GeoEngine.initBlockMatches(maxScanRegions);
    }

    public static void unload() {
        for (int index = 0; index < geodata.length; ++index) {
            for (int mapX = 0; mapX < World.WORLD_SIZE_X; ++mapX) {
                for (int mapY = 0; mapY < World.WORLD_SIZE_Y; ++mapY) {
                    GeoEngine.geodata[index][mapX][mapY] = null;
                }
            }
        }
    }

    public static int getGeoX(int worldX) {
        return GeoEngine.getGeoDistance(worldX - World.MAP_MIN_X);
    }

    public static int getGeoY(int worldY) {
        return GeoEngine.getGeoDistance(worldY - World.MAP_MIN_Y);
    }

    public static int getGeoDistance(int distance) {
        return distance >> 4;
    }

    public static int getGeoXYHash(int geoX, int geoY) {
        return geoX | geoY << 16;
    }

    public static int getGeoXFromHash(int hash) {
        int mask = 65535;
        return 0xFFFF & hash;
    }

    public static int getGeoYFromHash(int hash) {
        int mask = 65535;
        return 0xFFFF & hash >>> 16;
    }

    public static int getWorldX(int geoX) {
        return GeoEngine.getWorldDistance(geoX) + World.MAP_MIN_X + 8;
    }

    public static int getWorldY(int geoY) {
        return GeoEngine.getWorldDistance(geoY) + World.MAP_MIN_Y + 8;
    }

    public static int getWorldDistance(int geoDistance) {
        return geoDistance << 4;
    }

    static {
        GeoEngine.geodata[0] = new byte[World.WORLD_SIZE_X][World.WORLD_SIZE_Y][][];
    }

    public static enum CeilGeoControlType {
        NONE,
        PERIMETER,
        INSIDE;

    }

    /**
     * Checks if any closed door blocks line of sight between two world positions.
     * Uses 2D line segment intersection with door polygon edges + Z validation.
     */
    public static boolean checkIfDoorsBetween(int x, int y, int z, int tx, int ty, int tz) {
        WorldRegion region = World.getRegion(new Location(x, y, z));
        if (region == null) {
            return false;
        }
        for (GameObject obj : region) {
            if (obj == null || !obj.isDoor()) {
                continue;
            }
            DoorInstance door = (DoorInstance) obj;
            if (door.isOpen()) {
                continue;
            }
            DoorTemplate template = door.getTemplate();
            Polygon polygon = template.getPolygon();
            if (polygon == null) {
                continue;
            }
            Point2D[] points = polygon.getPoints();
            if (points == null || points.length < 2) {
                continue;
            }
            int doorZmin = polygon.getZmin();
            int doorZmax = polygon.getZmax();
            // Check each edge of the polygon for intersection with the line segment (x,y)-(tx,ty)
            for (int i = 0; i < points.length; i++) {
                int next = (i + 1) % points.length;
                int ax = points[i].x;
                int ay = points[i].y;
                int bx = points[next].x;
                int by = points[next].y;
                // Parametric 2D line segment intersection
                int dx = tx - x;
                int dy = ty - y;
                int ex = bx - ax;
                int ey = by - ay;
                long denom = (long) dx * ey - (long) dy * ex;
                if (denom == 0) {
                    continue; // parallel
                }
                long fx = ax - x;
                long fy = ay - y;
                double t = (double) (fx * ey - fy * ex) / denom;
                double u = (double) (fx * dy - fy * dx) / denom;
                if (t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0) {
                    // Intersection found, validate Z
                    int intersectZ = (int) (z + t * (tz - z));
                    if (intersectZ >= doorZmin && intersectZ <= doorZmax) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /**
     * Checks if any active fence blocks line of sight between two world positions.
     * Uses rectangle boundary tests + edge intersection with Z validation.
     */
    public static boolean checkIfFenceBetween(int x, int y, int z, int tx, int ty, int tz) {
        WorldRegion region = World.getRegion(new Location(x, y, z));
        if (region == null) {
            return false;
        }
        for (GameObject obj : region) {
            if (obj == null || !obj.isFence()) {
                continue;
            }
            FenceInstance fence = (FenceInstance) obj;
            if (!fence.getState().isGeodataEnabled()) {
                continue;
            }
            int fenceX = fence.getX();
            int fenceY = fence.getY();
            int fenceZ = fence.getZ();
            int halfWidth = fence.getWidth() / 2;
            int halfLength = fence.getLength() / 2;
            int xMin = fenceX - halfWidth;
            int xMax = fenceX + halfWidth;
            int yMin = fenceY - halfLength;
            int yMax = fenceY + halfLength;
            int zMin = fenceZ - 100;
            int zMax = fenceZ + 100;
            // Quick reject: both points on same side of the fence bounds
            if (x < xMin && tx < xMin) continue;
            if (x > xMax && tx > xMax) continue;
            if (y < yMin && ty < yMin) continue;
            if (y > yMax && ty > yMax) continue;
            // Check 4 rectangle edges
            int[][] edges = {
                {xMin, yMin, xMax, yMin},
                {xMax, yMin, xMax, yMax},
                {xMax, yMax, xMin, yMax},
                {xMin, yMax, xMin, yMin}
            };
            for (int[] edge : edges) {
                int ax = edge[0];
                int ay = edge[1];
                int bx = edge[2];
                int by = edge[3];
                int dx = tx - x;
                int dy = ty - y;
                int ex = bx - ax;
                int ey = by - ay;
                long denom = (long) dx * ey - (long) dy * ex;
                if (denom == 0) {
                    continue; // parallel
                }
                long fx = ax - x;
                long fy = ay - y;
                double t = (double) (fx * ey - fy * ex) / denom;
                double u = (double) (fx * dy - fy * dx) / denom;
                if (t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0) {
                    // Intersection found, validate Z
                    int intersectZ = (int) (z + t * (tz - z));
                    if (intersectZ >= zMin && intersectZ <= zMax) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
