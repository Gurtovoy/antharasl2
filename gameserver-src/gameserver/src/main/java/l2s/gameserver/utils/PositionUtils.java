/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.geometry.GeometryUtils
 */
package l2s.gameserver.utils;

import java.util.List;
import l2s.commons.geometry.GeometryUtils;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;

public class PositionUtils {
    private static final int MAX_ANGLE = 360;
    private static final double FRONT_MAX_ANGLE = 100.0;
    private static final double BACK_MAX_ANGLE = 40.0;

    public static TargetDirection getDirectionTo(Creature target, Creature attacker) {
        if (target == null || attacker == null) {
            return TargetDirection.NONE;
        }
        if (PositionUtils.isBehind(target, attacker)) {
            return TargetDirection.BEHIND;
        }
        if (PositionUtils.isInFrontOf(target, attacker)) {
            return TargetDirection.FRONT;
        }
        return TargetDirection.SIDE;
    }

    public static boolean isInFrontOf(Creature target, Creature attacker) {
        if (target == null) {
            return false;
        }
        double angleTarget = PositionUtils.calculateAngleFrom(target, attacker);
        double angleChar = PositionUtils.convertHeadingToDegree(target.getHeading());
        double angleDiff = angleChar - angleTarget;
        if (angleDiff <= -260.0) {
            angleDiff += 360.0;
        }
        if (angleDiff >= 260.0) {
            angleDiff -= 360.0;
        }
        return Math.abs(angleDiff) <= 100.0;
    }

    public static boolean isBehind(Creature target, Creature attacker) {
        double angleTarget;
        if (target == null) {
            return false;
        }
        double angleChar = PositionUtils.calculateAngleFrom(attacker, target);
        double angleDiff = angleChar - (angleTarget = PositionUtils.convertHeadingToDegree(target.getHeading()));
        if (angleDiff <= -320.0) {
            angleDiff += 360.0;
        }
        if (angleDiff >= 320.0) {
            angleDiff -= 360.0;
        }
        return Math.abs(angleDiff) <= 40.0;
    }

    public static boolean isFacing(Creature attacker, GameObject target, int maxAngle) {
        if (target == null) {
            return false;
        }
        if (maxAngle >= 360) {
            return true;
        }
        double maxAngleDiff = maxAngle / 2;
        double angleTarget = PositionUtils.calculateAngleFrom(attacker, target);
        double angleChar = PositionUtils.convertHeadingToDegree(attacker.getHeading());
        double angleDiff = angleChar - angleTarget;
        if (angleDiff <= -360.0 + maxAngleDiff) {
            angleDiff += 360.0;
        }
        if (angleDiff >= 360.0 - maxAngleDiff) {
            angleDiff -= 360.0;
        }
        return Math.abs(angleDiff) <= maxAngleDiff;
    }

    public static int calculateHeadingFrom(GameObject obj1, GameObject obj2) {
        return PositionUtils.calculateHeadingFrom(obj1.getX(), obj1.getY(), obj2.getX(), obj2.getY());
    }

    public static int calculateHeadingFrom(int obj1X, int obj1Y, int obj2X, int obj2Y) {
        double angleTarget = Math.toDegrees(Math.atan2(obj2Y - obj1Y, obj2X - obj1X));
        if (angleTarget < 0.0) {
            angleTarget = 360.0 + angleTarget;
        }
        return (int)(angleTarget * 182.044444444);
    }

    public static double calculateAngleFrom(GameObject obj1, GameObject obj2) {
        return PositionUtils.calculateAngleFrom(obj1.getX(), obj1.getY(), obj2.getX(), obj2.getY());
    }

    public static double calculateAngleFrom(int obj1X, int obj1Y, int obj2X, int obj2Y) {
        return GeometryUtils.calculateAngleFrom((int)obj1X, (int)obj1Y, (int)obj2X, (int)obj2Y);
    }

    public static boolean checkIfInRange(int range, int x1, int y1, int x2, int y2) {
        return PositionUtils.checkIfInRange(range, x1, y1, 0, x2, y2, 0, false);
    }

    public static boolean checkIfInRange(int range, int x1, int y1, int z1, int x2, int y2, int z2, boolean includeZAxis) {
        long dx = x1 - x2;
        long dy = y1 - y2;
        if (includeZAxis) {
            long dz = z1 - z2;
            return dx * dx + dy * dy + dz * dz <= (long)(range * range);
        }
        return dx * dx + dy * dy <= (long)(range * range);
    }

    public static boolean checkIfInRange(int range, GameObject obj1, GameObject obj2, boolean includeZAxis) {
        if (obj1 == null || obj2 == null) {
            return false;
        }
        return PositionUtils.checkIfInRange(range, obj1.getX(), obj1.getY(), obj1.getZ(), obj2.getX(), obj2.getY(), obj2.getZ(), includeZAxis);
    }

    public static double convertHeadingToDegree(int heading) {
        return (double)heading / 182.044444444;
    }

    public static double convertHeadingToRadian(int heading) {
        return Math.toRadians(PositionUtils.convertHeadingToDegree(heading) - 90.0);
    }

    public static int convertDegreeToClientHeading(double degree) {
        if (degree < 0.0) {
            degree = 360.0 + degree;
        }
        return (int)(degree * 182.044444444);
    }

    public static int calculateDistance(int x1, int y1, int x2, int y2) {
        return GeometryUtils.calculateDistance((int)x1, (int)y1, (int)x2, (int)y2);
    }

    public static int calculateDistance(int x1, int y1, int z1, int x2, int y2, int z2, boolean includeZAxis) {
        return GeometryUtils.calculateDistance((int)x1, (int)y1, (int)z1, (int)x2, (int)y2, (int)z2, (boolean)includeZAxis);
    }

    public static int calculateDistance(GameObject obj1, GameObject obj2, boolean includeZAxis) {
        if (obj1 == null || obj2 == null) {
            return Integer.MAX_VALUE;
        }
        return PositionUtils.calculateDistance(obj1.getX(), obj1.getY(), obj1.getZ(), obj2.getX(), obj2.getY(), obj2.getZ(), includeZAxis);
    }

    public static int getDistance(GameObject a1, GameObject a2) {
        return PositionUtils.getDistance(a1.getX(), a2.getY(), a2.getX(), a2.getY());
    }

    public static int getDistance(Location loc1, Location loc2) {
        return PositionUtils.getDistance(loc1.getX(), loc1.getY(), loc2.getX(), loc2.getY());
    }

    public static int getDistance(int x1, int y1, int x2, int y2) {
        return (int)Math.hypot(x1 - x2, y1 - y2);
    }

    public static int getHeadingTo(GameObject actor, GameObject target) {
        if (actor == null || target == null || target == actor) {
            return -1;
        }
        return PositionUtils.getHeadingTo(actor.getLoc(), target.getLoc());
    }

    public static int getHeadingTo(Location actor, Location target) {
        if (actor == null || target == null || target.equals(actor)) {
            return -1;
        }
        int dy = target.y - actor.y;
        int dx = target.x - actor.x;
        int heading = target.h - (int)(Math.atan2(-dy, -dx) * 10430.378350470453 + 32768.0);
        if (heading < 0) {
            heading = heading + 1 + Integer.MAX_VALUE & 0xFFFF;
        } else if (heading > 65535) {
            heading &= 0xFFFF;
        }
        return heading;
    }

    public static Location applyOffset(Creature activeChar, Location point, int offset) {
        long dz;
        long dy;
        if (offset <= 0) {
            return point;
        }
        long dx = point.x - activeChar.getX();
        double distance = Math.sqrt(dx * dx + (dy = (long)(point.y - activeChar.getY())) * dy + (dz = (long)(point.z - activeChar.getZ())) * dz);
        if (distance <= (double)offset) {
            point.set(activeChar.getX(), activeChar.getY(), activeChar.getZ());
            return point;
        }
        if (distance >= 1.0) {
            double cut = (double)offset / distance;
            point.x -= (int)((double)dx * cut + 0.5);
            point.y -= (int)((double)dy * cut + 0.5);
            point.z -= (int)((double)dz * cut + 0.5);
            if (!(activeChar.isFlying() || activeChar.isInBoat() || activeChar.isInWater() || activeChar.isBoat())) {
                point.correctGeoZ(activeChar.getGeoIndex());
            }
        }
        return point;
    }

    public static List<Location> applyOffset(List<Location> points, int offset) {
        if ((offset >>= 4) <= 0) {
            return points;
        }
        long dx = points.get((int)(points.size() - 1)).x - points.get((int)0).x;
        long dy = points.get((int)(points.size() - 1)).y - points.get((int)0).y;
        long dz = points.get((int)(points.size() - 1)).z - points.get((int)0).z;
        double distance = Math.sqrt(dx * dx + dy * dy + dz * dz);
        if (distance <= (double)offset) {
            Location point = points.get(0);
            points.clear();
            points.add(point);
            return points;
        }
        if (distance >= 1.0) {
            double cut = (double)offset / distance;
            int num = (int)((double)points.size() * cut + 0.5);
            for (int i = 1; i <= num && points.size() > 0; ++i) {
                points.remove(points.size() - 1);
            }
        }
        return points;
    }

    public static enum TargetDirection {
        NONE,
        FRONT,
        SIDE,
        BEHIND;

    }
}

