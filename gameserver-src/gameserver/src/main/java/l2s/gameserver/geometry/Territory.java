/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.geometry.CoordsConverter
 *  l2s.commons.geometry.GeometryUtils
 *  l2s.commons.geometry.Point2D
 *  l2s.commons.geometry.Point3D
 *  l2s.commons.geometry.Shape
 *  l2s.commons.util.Rnd
 *  org.napile.primitive.sets.impl.HashIntSet
 */
package l2s.gameserver.geometry;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.geometry.CoordsConverter;
import l2s.commons.geometry.GeometryUtils;
import l2s.commons.geometry.Point2D;
import l2s.commons.geometry.Point3D;
import l2s.commons.geometry.Shape;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExShowTerritory;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.utils.PositionUtils;
import org.napile.primitive.sets.impl.HashIntSet;

public class Territory
implements Shape,
SpawnRange {
    private static final int RANDOM_LOC_FIND_ATTEMPTS = 100;
    protected final Point3D max = new Point3D();
    protected final Point3D min = new Point3D();
    private final List<Shape> include = new ArrayList<Shape>(1);
    private final List<Shape> exclude = new ArrayList<Shape>(1);
    protected int radius = 0;

    public Territory add(Shape shape) {
        if (this.include.isEmpty()) {
            this.max.x = shape.getXmax();
            this.max.y = shape.getYmax();
            this.max.z = shape.getZmax();
            this.min.x = shape.getXmin();
            this.min.y = shape.getYmin();
            this.min.z = shape.getZmin();
        } else {
            this.max.x = Math.max(this.max.x, shape.getXmax());
            this.max.y = Math.max(this.max.y, shape.getYmax());
            this.max.z = Math.max(this.max.z, shape.getZmax());
            this.min.x = Math.min(this.min.x, shape.getXmin());
            this.min.y = Math.min(this.min.y, shape.getYmin());
            this.min.z = Math.min(this.min.z, shape.getZmin());
        }
        this.include.add(shape);
        this.radius = Math.max(this.radius, shape.getRadius());
        return this;
    }

    public Territory addBanned(Shape shape) {
        this.exclude.add(shape);
        return this;
    }

    public List<Shape> getTerritories() {
        return this.include;
    }

    public List<Shape> getBannedTerritories() {
        return this.exclude;
    }

    public boolean isInside(int x, int y, CoordsConverter c) {
        for (Shape shape : this.include) {
            if (!shape.isInside(x, y, c)) continue;
            return !this.isExcluded(x, y, c);
        }
        return false;
    }

    public boolean isInside(int x, int y, int z, CoordsConverter c) {
        if (x < c.convertX(this.min.x) || x > c.convertX(this.max.x) || y < c.convertY(this.min.y) || y > c.convertY(this.max.y) || z < this.min.z || z > this.max.z) {
            return false;
        }
        for (Shape shape : this.include) {
            if (!shape.isInside(x, y, z, c)) continue;
            return !this.isExcluded(x, y, z, c);
        }
        return false;
    }

    public boolean isOnPerimeter(int x, int y, CoordsConverter c) {
        for (Shape shape : this.include) {
            if (!shape.isOnPerimeter(x, y, c) || this.isExcluded(x, y, c)) continue;
            return true;
        }
        for (Shape shape : this.exclude) {
            if (!shape.isOnPerimeter(x, y, c) || !this.isInside(x, y, c)) continue;
            return true;
        }
        return false;
    }

    public boolean isOnPerimeter(int x, int y, int z, CoordsConverter c) {
        if (x < c.convertX(this.min.x) || x > c.convertX(this.max.x) || y < c.convertY(this.min.y) || y > c.convertY(this.max.y) || z < this.min.z || z > this.max.z) {
            return false;
        }
        for (Shape shape : this.include) {
            if (!shape.isOnPerimeter(x, y, z) || this.isExcluded(x, y, z, c)) continue;
            return true;
        }
        for (Shape shape : this.exclude) {
            if (!shape.isOnPerimeter(x, y, z, c) || !this.isInside(x, y, z, c)) continue;
            return true;
        }
        return false;
    }

    public boolean isInside(GameObject obj) {
        return this.isInside(obj.getLoc());
    }

    public boolean isInside(Location loc) {
        return this.isInside(loc.x, loc.y, loc.z);
    }

    public boolean isExcluded(int x, int y, CoordsConverter c) {
        for (int i = 0; i < this.exclude.size(); ++i) {
            Shape shape = this.exclude.get(i);
            if (!shape.isInside(x, y, c)) continue;
            return true;
        }
        return false;
    }

    public boolean isExcluded(int x, int y, int z, CoordsConverter c) {
        for (int i = 0; i < this.exclude.size(); ++i) {
            Shape shape = this.exclude.get(i);
            if (!shape.isInside(x, y, z, c)) continue;
            return true;
        }
        return false;
    }

    public int getXmax() {
        return this.max.x;
    }

    public int getXmin() {
        return this.min.x;
    }

    public int getYmax() {
        return this.max.y;
    }

    public int getYmin() {
        return this.min.y;
    }

    public int getZmax() {
        return this.max.z;
    }

    public int getZmin() {
        return this.min.z;
    }

    public static Location getRandomLoc(Territory territory, boolean fly) {
        return Territory.getRandomLoc(territory, 0, fly);
    }

    public static Location getRandomLoc(Territory territory, int geoIndex, boolean fly) {
        Location pos = new Location();
        List<Shape> territories = territory.getTerritories();
        for (int i = 1; i <= 100; ++i) {
            Shape shape = territories.get(Rnd.get((int)territories.size()));
            pos.x = Rnd.get((int)shape.getXmin(), (int)shape.getXmax());
            pos.y = Rnd.get((int)shape.getYmin(), (int)shape.getYmax());
            int minZ = Math.min(shape.getZmin(), shape.getZmax());
            int maxZ = Math.max(shape.getZmin(), shape.getZmax());
            if (territory.isInside(pos.x, pos.y)) {
                if (fly) {
                    pos.z = Rnd.get((int)minZ, (int)maxZ);
                    break;
                }
                if (minZ == maxZ) {
                    minZ -= 200;
                    maxZ += 200;
                }
                pos.z = maxZ;
                if (!Config.ALLOW_GEODATA) break;
                HashIntSet zSet = new HashIntSet();
                int tempz = maxZ;
                block1: for (int l = 1; l <= GeoEngine.MAX_LAYERS && (tempz = GeoEngine.getLowerHeight(pos.x, pos.y, tempz, geoIndex)) >= minZ; ++l) {
                    if (!zSet.contains(tempz)) {
                        int geoX = GeoEngine.getGeoX(pos.x);
                        int geoY = GeoEngine.getGeoY(pos.y);
                        for (int x = geoX - 1; x <= geoX + 1; ++x) {
                            for (int y = geoY - 1; y <= geoY + 1; ++y) {
                                if (GeoEngine.NgetLowerNSWE(x, y, (short)(tempz + Config.MIN_LAYER_HEIGHT), geoIndex) != 15) continue block1;
                            }
                        }
                        zSet.add(tempz);
                    }
                    tempz -= Config.MIN_LAYER_HEIGHT;
                }
                if (zSet.isEmpty()) continue;
                pos.z = Rnd.get((int[])zSet.toArray());
                break;
            }
            if (i != 100) continue;
            pos.z = GeoEngine.correctGeoZ(pos.x, pos.y, maxZ, geoIndex);
            break;
        }
        pos.h = Location.getRandomHeading();
        return pos;
    }

    public double getDistance(Location loc) {
        Point2D nearestPoint = this.getNearestPoint(loc.getX(), loc.getY());
        return PositionUtils.getDistance(nearestPoint.x, nearestPoint.y, loc.getX(), loc.getY());
    }

    @Override
    public Location getRandomLoc(int geoIndex, boolean fly) {
        return Territory.getRandomLoc(this, geoIndex, fly);
    }

    public Point2D getCenter() {
        return GeometryUtils.getLineCenter((int)this.min.x, (int)this.min.y, (int)this.max.x, (int)this.max.y);
    }

    public Point2D getNearestPoint(int x, int y) {
        Point2D n;
        Point2D nearestPoint = new Point2D();
        for (Shape shape : this.include) {
            n = shape.getNearestPoint(x, y);
            if (GeometryUtils.calculateDistance((int)n.x, (int)n.y, (int)x, (int)y) >= GeometryUtils.calculateDistance((int)nearestPoint.x, (int)nearestPoint.y, (int)x, (int)y) || this.isExcluded(x, y, CoordsConverter.DEFAULT_CONVERTER)) continue;
            nearestPoint = n;
        }
        for (Shape shape : this.exclude) {
            n = shape.getNearestPoint(x, y);
            if (GeometryUtils.calculateDistance((int)n.x, (int)n.y, (int)x, (int)y) >= GeometryUtils.calculateDistance((int)nearestPoint.x, (int)nearestPoint.y, (int)x, (int)y) || !this.isInside(x, y)) continue;
            nearestPoint = n;
        }
        return nearestPoint;
    }

    public int getRadius() {
        return this.radius;
    }

    public Point2D[] getPoints() {
        ArrayList<Point2D> points = new ArrayList<Point2D>();
        for (Shape shape : this.include) {
            for (Point2D point : shape.getPoints()) {
                points.add(point);
            }
        }
        for (Shape shape : this.exclude) {
            for (Point2D point : shape.getPoints()) {
                points.add(point);
            }
        }
        return points.toArray(new Point2D[points.size()]);
    }

    public void printToWorld(Player player) {
        for (Shape shape : this.include) {
            player.sendPacket((IBroadcastPacket)new ExShowTerritory(shape));
        }
        for (Shape shape : this.exclude) {
            player.sendPacket((IBroadcastPacket)new ExShowTerritory(shape));
        }
    }
}

