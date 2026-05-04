/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.geometry;

import l2s.commons.geometry.Point3D;
import l2s.commons.util.Rnd;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.World;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.utils.PositionUtils;
import org.dom4j.Element;

public class Location
extends Point3D
implements ILocation,
SpawnRange {
    public int h;

    public Location() {
    }

    public Location(int x, int y, int z, int heading) {
        super(x, y, z);
        this.h = heading;
    }

    public Location(int x, int y, int z) {
        this(x, y, z, 0);
    }

    public Location(int[] xyz) {
        this(xyz[0], xyz[1], xyz[2], 0);
    }

    public Location(ILocation loc) {
        this(loc.getX(), loc.getY(), loc.getZ(), loc.getHeading());
    }

    public Location changeZ(int zDiff) {
        this.z += zDiff;
        return this;
    }

    public Location correctGeoZ(int geoIndex) {
        this.z = GeoEngine.correctGeoZ(this.x, this.y, this.z, geoIndex);
        return this;
    }

    public Location setX(int x) {
        this.x = x;
        return this;
    }

    public Location setY(int y) {
        this.y = y;
        return this;
    }

    public Location setZ(int z) {
        this.z = z;
        return this;
    }

    public Location setH(int h) {
        this.h = h;
        return this;
    }

    public Location set(int x, int y, int z) {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    public Location set(int x, int y, int z, int h) {
        this.set(x, y, z);
        this.h = h;
        return this;
    }

    public Location set(Location loc) {
        this.x = loc.x;
        this.y = loc.y;
        this.z = loc.z;
        this.h = loc.h;
        return this;
    }

    @Override
    public int getHeading() {
        return this.h;
    }

    public Location world2geo() {
        this.x = this.x - World.MAP_MIN_X >> 4;
        this.y = this.y - World.MAP_MIN_Y >> 4;
        return this;
    }

    public Location geo2world() {
        this.x = (this.x << 4) + World.MAP_MIN_X + 8;
        this.y = (this.y << 4) + World.MAP_MIN_Y + 8;
        return this;
    }

    public Location clone() {
        return new Location(this.x, this.y, this.z, this.h);
    }

    public final String toString() {
        return this.x + "," + this.y + "," + this.z + "," + this.h;
    }

    public boolean isNull() {
        return this.x == 0 || this.y == 0 || this.z == 0;
    }

    public final String toXYZString() {
        return this.x + " " + this.y + " " + this.z;
    }

    public static Location parseLoc(String s) throws IllegalArgumentException {
        String[] xyzh = s.split("[\\s,;]+");
        if (xyzh.length < 3) {
            throw new IllegalArgumentException("Can't parse location from string: " + s);
        }
        int x = Integer.parseInt(xyzh[0]);
        int y = Integer.parseInt(xyzh[1]);
        int z = Integer.parseInt(xyzh[2]);
        int h = xyzh.length < 4 ? 0 : Integer.parseInt(xyzh[3]);
        return new Location(x, y, z, h);
    }

    public static Location parse(Element element) {
        int x = Integer.parseInt(element.attributeValue("x"));
        int y = Integer.parseInt(element.attributeValue("y"));
        int z = Integer.parseInt(element.attributeValue("z"));
        int h = element.attributeValue("h") == null ? 0 : Integer.parseInt(element.attributeValue("h"));
        return new Location(x, y, z, h);
    }

    public static Location findFrontPosition(GameObject obj, GameObject obj2, int radiusmin, int radiusmax) {
        if (radiusmax <= 0 || radiusmax < radiusmin) {
            return new Location(obj);
        }
        double collision = obj.getCurrentCollisionRadius() + obj2.getCurrentCollisionRadius();
        int minangle = 0;
        int maxangle = 360;
        if (!obj.equals(obj2)) {
            double angle = PositionUtils.calculateAngleFrom(obj, obj2);
            minangle = (int)angle - 45;
            maxangle = (int)angle + 45;
        }
        Location pos = new Location();
        for (int i = 0; i < 100; ++i) {
            int randomRadius = Rnd.get((int)radiusmin, (int)radiusmax);
            int randomAngle = Rnd.get((int)minangle, (int)maxangle);
            pos.x = obj.getX() + (int)((collision + (double)randomRadius) * Math.cos(Math.toRadians(randomAngle)));
            pos.y = obj.getY() + (int)((collision + (double)randomRadius) * Math.sin(Math.toRadians(randomAngle)));
            pos.z = obj.getZ();
            int tempz = GeoEngine.getLowerHeight(pos.x, pos.y, pos.z, obj.getGeoIndex());
            if (Math.abs(pos.z - tempz) >= 200 || GeoEngine.getLowerNSWE(pos.x, pos.y, tempz, obj.getGeoIndex()) != 15) continue;
            pos.z = tempz;
            pos.h = !obj.equals(obj2) ? PositionUtils.getHeadingTo(pos, obj2.getLoc()) : obj.getHeading();
            return pos;
        }
        return new Location(obj);
    }

    public static Location findAroundPosition(int x, int y, int z, int radiusmin, int radiusmax, int geoIndex) {
        if (radiusmax <= 0 || radiusmax < radiusmin) {
            return new Location(x, y, z);
        }
        for (int i = 0; i < 100; ++i) {
            Location pos = Location.coordsRandomize(x, y, z, 0, radiusmin, radiusmax);
            int tempz = GeoEngine.getLowerHeight(pos.x, pos.y, pos.z, geoIndex);
            if (!GeoEngine.canMoveToCoord(x, y, z, pos.x, pos.y, tempz, geoIndex) || !GeoEngine.canMoveToCoord(pos.x, pos.y, tempz, x, y, z, geoIndex)) continue;
            pos.z = tempz;
            return pos;
        }
        return new Location(x, y, z);
    }

    public static Location findAroundPosition(Location loc, int radius, int geoIndex) {
        return Location.findAroundPosition(loc.x, loc.y, loc.z, 0, radius, geoIndex);
    }

    public static Location findAroundPosition(Location loc, int radiusmin, int radiusmax, int geoIndex) {
        return Location.findAroundPosition(loc.x, loc.y, loc.z, radiusmin, radiusmax, geoIndex);
    }

    public static Location findAroundPosition(GameObject obj, Location loc, int radiusmin, int radiusmax) {
        return Location.findAroundPosition(loc.x, loc.y, loc.z, radiusmin, radiusmax, obj.getGeoIndex());
    }

    public static Location findAroundPosition(GameObject obj, int radiusmin, int radiusmax) {
        return Location.findAroundPosition(obj, obj.getLoc(), radiusmin, radiusmax);
    }

    public static Location findAroundPosition(GameObject obj, int radius) {
        return Location.findAroundPosition(obj, 0, radius);
    }

    public static Location findPointToStay(int x, int y, int z, int radiusmin, int radiusmax, int geoIndex, int maxZDiff) {
        if (radiusmax <= 0 || radiusmax < radiusmin) {
            return new Location(x, y, z);
        }
        for (int i = 0; i < 100; ++i) {
            Location pos = Location.coordsRandomize(x, y, z, 0, radiusmin, radiusmax);
            int tempz = GeoEngine.getLowerHeight(pos.x, pos.y, pos.z, geoIndex);
            if (Math.abs(pos.z - tempz) >= maxZDiff || GeoEngine.getLowerNSWE(pos.x, pos.y, tempz, geoIndex) != 15) continue;
            pos.z = tempz;
            return pos;
        }
        return new Location(x, y, z);
    }

    public static Location findPointToStay(int x, int y, int z, int radiusmin, int radiusmax, int geoIndex) {
        return Location.findPointToStay(x, y, z, radiusmin, radiusmax, geoIndex, 200);
    }

    public static Location findPointToStay(Location loc, int radius, int geoIndex) {
        return Location.findPointToStay(loc.x, loc.y, loc.z, 0, radius, geoIndex);
    }

    public static Location findPointToStay(Location loc, int radiusmin, int radiusmax, int geoIndex) {
        return Location.findPointToStay(loc.x, loc.y, loc.z, radiusmin, radiusmax, geoIndex);
    }

    public static Location findPointToStay(GameObject obj, Location loc, int radiusmin, int radiusmax) {
        return Location.findPointToStay(loc.x, loc.y, loc.z, radiusmin, radiusmax, obj.getGeoIndex());
    }

    public static Location findPointToStay(GameObject obj, int radiusmin, int radiusmax) {
        return Location.findPointToStay(obj, obj.getLoc(), radiusmin, radiusmax);
    }

    public static Location findPointToStay(GameObject obj, int radius) {
        return Location.findPointToStay(obj, 0, radius);
    }

    public static Location coordsRandomize(ILocation loc, int radiusmin, int radiusmax) {
        return Location.coordsRandomize(loc.getX(), loc.getY(), loc.getZ(), loc.getHeading(), radiusmin, radiusmax);
    }

    public static Location coordsRandomize(int x, int y, int z, int heading, int radiusmin, int radiusmax) {
        if (radiusmax <= 0 || radiusmax < radiusmin) {
            return new Location(x, y, z, heading);
        }
        int radius = Rnd.get((int)radiusmin, (int)radiusmax);
        double angle = Rnd.nextDouble() * 2.0 * Math.PI;
        return new Location((int)((double)x + (double)radius * Math.cos(angle)), (int)((double)y + (double)radius * Math.sin(angle)), z, heading);
    }

    public static Location findNearest(ILocation loc, Location[] locs) {
        Location defloc = null;
        for (Location l : locs) {
            if (defloc == null) {
                defloc = l;
                continue;
            }
            if (loc.getDistance(l) >= loc.getDistance(defloc)) continue;
            defloc = l;
        }
        return defloc;
    }

    public static int getRandomHeading() {
        return Rnd.get((int)65535);
    }

    @Override
    public Location getRandomLoc(int geoIndex, boolean fly) {
        Location loc = this.clone();
        if (loc.h == -1) {
            loc.h = Location.getRandomHeading();
        }
        return loc;
    }
}

