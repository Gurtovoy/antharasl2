/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.geometry;

import l2s.commons.geometry.CoordsConverter;
import l2s.commons.geometry.Point2D;
import l2s.commons.geometry.Point3D;

public class GeometryUtils {
    private GeometryUtils() {
    }

    public static boolean checkIfLinesIntersects(Point2D a, Point2D b, Point2D c, Point2D d) {
        return GeometryUtils.checkIfLinesIntersects(a, b, c, d, null);
    }

    public static boolean checkIfLinesIntersects(Point2D a, Point2D b, Point2D c, Point2D d, Point2D r) {
        if (a.x == b.x && a.y == b.y || c.x == d.x && c.y == d.y) {
            return false;
        }
        double Bx = b.x - a.x;
        double By = b.y - a.y;
        double Cx = c.x - a.x;
        double Cy = c.y - a.y;
        double Dx = d.x - a.x;
        double Dy = d.y - a.y;
        double distAB = Math.sqrt(Bx * Bx + By * By);
        double theCos = Bx / distAB;
        double theSin = By / distAB;
        double newX = Cx * theCos + Cy * theSin;
        Cy = (int)(Cy * theCos - Cx * theSin);
        Cx = newX;
        newX = Dx * theCos + Dy * theSin;
        Dy = (int)(Dy * theCos - Dx * theSin);
        Dx = newX;
        if (Cy == Dy) {
            return false;
        }
        double ABpos = Dx + (Cx - Dx) * Dy / (Dy - Cy);
        if (r != null) {
            r.x = (int)((double)a.x + ABpos * theCos);
            r.y = (int)((double)a.y + ABpos * theSin);
        }
        return true;
    }

    public static boolean checkIfLineSegementsIntersects(Point2D a, Point2D b, Point2D c, Point2D d) {
        return GeometryUtils.checkIfLineSegementsIntersects(a, b, c, d, null);
    }

    public static boolean checkIfLineSegementsIntersects(Point2D a, Point2D b, Point2D c, Point2D d, Point2D r) {
        if (a.x == b.x && a.y == b.y || c.x == d.x && c.y == d.y) {
            return false;
        }
        if (a.x == c.x && a.y == c.y || b.x == c.x && b.y == c.y || a.x == d.x && a.y == d.y || b.x == d.x && b.y == d.y) {
            return false;
        }
        double Bx = b.x - a.x;
        double By = b.y - a.y;
        double Cx = c.x - a.x;
        double Cy = c.y - a.y;
        double Dx = d.x - a.x;
        double Dy = d.y - a.y;
        double distAB = Math.sqrt(Bx * Bx + By * By);
        double theCos = Bx / distAB;
        double theSin = By / distAB;
        double newX = Cx * theCos + Cy * theSin;
        Cy = (int)(Cy * theCos - Cx * theSin);
        Cx = newX;
        newX = Dx * theCos + Dy * theSin;
        Dy = (int)(Dy * theCos - Dx * theSin);
        Dx = newX;
        if (Cy < 0.0 && Dy < 0.0 || Cy >= 0.0 && Dy >= 0.0) {
            return false;
        }
        double ABpos = Dx + (Cx - Dx) * Dy / (Dy - Cy);
        if (ABpos < 0.0 || ABpos > distAB) {
            return false;
        }
        if (r != null) {
            r.x = (int)((double)a.x + ABpos * theCos);
            r.y = (int)((double)a.y + ABpos * theSin);
        }
        return true;
    }

    public static int calculateDistance(Point2D a, Point2D b) {
        return GeometryUtils.calculateDistance(a.x, a.y, b.x, b.y);
    }

    public static int calculateDistance(Point3D a, Point3D b, boolean includeZAxis) {
        return GeometryUtils.calculateDistance(a.x, a.y, a.z, b.x, b.y, b.z, includeZAxis);
    }

    public static int calculateDistance(int x1, int y1, int x2, int y2) {
        return GeometryUtils.calculateDistance(x1, y1, 0, x2, y2, 0, false);
    }

    public static int calculateDistance(int x1, int y1, int z1, int x2, int y2, int z2, boolean includeZAxis) {
        long dx = x1 - x2;
        long dy = y1 - y2;
        if (includeZAxis) {
            long dz = z1 - z2;
            return (int)Math.sqrt(dx * dx + dy * dy + dz * dz);
        }
        return (int)Math.sqrt(dx * dx + dy * dy);
    }

    public static double calculateAngleFrom(Point2D a, Point2D b) {
        return GeometryUtils.calculateAngleFrom(a.x, a.y, b.x, b.y);
    }

    public static double calculateAngleFrom(int x1, int y1, int x2, int y2) {
        double angleTarget = Math.toDegrees(Math.atan2(y2 - y1, x2 - x1));
        if (angleTarget < 0.0) {
            angleTarget = 360.0 + angleTarget;
        }
        return angleTarget;
    }

    public static Point2D applyOffset(Point2D a, Point2D b, int offset, boolean add) {
        Point2D result = new Point2D();
        if (offset <= 0) {
            result.x = a.x;
            result.y = a.y;
            return result;
        }
        long dx = a.x - b.x;
        long dy = a.y - b.y;
        double distance = Math.sqrt(dx * dx + dy * dy);
        if (!add) {
            if (distance <= (double)offset) {
                result.x = b.x;
                result.y = b.y;
                return result;
            }
        } else {
            offset = (int)((double)offset + distance);
        }
        if (distance >= 1.0) {
            double cut = (double)offset / distance;
            result.x = a.x - (int)((double)dx * cut + 0.5);
            result.y = a.y - (int)((double)dy * cut + 0.5);
        }
        return result;
    }

    public static Point2D applyOffset(int x1, int y1, int x2, int y2, int offset, boolean add) {
        return GeometryUtils.applyOffset(new Point2D(x1, y1), new Point2D(x2, y2), offset, add);
    }

    public static boolean isOnLine(Point2D a, Point2D b, int x, int y, CoordsConverter c) {
        return (x - c.convertX(a.x)) * (c.convertY(b.y) - c.convertY(a.y)) - (c.convertX(b.x) - c.convertX(a.x)) * (y - c.convertY(a.y)) == 0;
    }

    public static Point2D getLineCenter(Point2D a, Point2D b) {
        return GeometryUtils.getLineCenter(a.x, a.y, b.x, b.y);
    }

    public static Point2D getLineCenter(int x1, int y1, int x2, int y2) {
        return new Point2D((x1 + x2) / 2, (y1 + y2) / 2);
    }

    public static Point2D getNearestPointOnCircle(Point2D center, int r, int x, int y) {
        return GeometryUtils.applyOffset(center, new Point2D(x, y), r, false);
    }

    public static Point2D getNearestPointOnLine(Point2D p1, Point2D p2, int x, int y) {
        Point2D nearestPoint = new Point2D();
        int r1 = GeometryUtils.calculateDistance(p1.x, p1.y, x, y);
        Point2D np1 = GeometryUtils.getNearestPointOnCircle(p1, r1, p2.x, p2.y);
        int r2 = GeometryUtils.calculateDistance(p2.x, p2.y, x, y);
        Point2D np2 = GeometryUtils.getNearestPointOnCircle(p2, r2, p1.x, p1.y);
        return GeometryUtils.getLineCenter(np1, np2);
    }

    public static Point2D getNearestPointOnPolygon(Point2D[] points, int x, int y) {
        Point2D nearestPoint = new Point2D();
        if (points.length == 0) {
            nearestPoint = null;
        } else if (points.length == 1) {
            nearestPoint.x = points[0].x;
            nearestPoint.y = points[0].y;
        } else {
            for (int i = 1; i <= points.length; ++i) {
                Point2D p1 = points[i - 1];
                Point2D p2 = i == points.length ? points[0] : points[i];
                Point2D n = GeometryUtils.getNearestPointOnLine(p1, p2, x, y);
                if (GeometryUtils.calculateDistance(n.x, n.y, x, y) >= GeometryUtils.calculateDistance(nearestPoint.x, nearestPoint.y, x, y)) continue;
                nearestPoint = n;
            }
        }
        return nearestPoint;
    }

    public static boolean isOnPolygonPerimeter(Point2D[] points, int x, int y, CoordsConverter c) {
        if (points.length == 0) {
            return false;
        }
        if (points.length == 1) {
            return c.convertX(points[0].x) == x && c.convertY(points[1].y) == y;
        }
        for (int i = 1; i <= points.length; ++i) {
            Point2D p2;
            Point2D p1 = points[i - 1];
            Point2D point2D = p2 = i == points.length ? points[0] : points[i];
            if (!GeometryUtils.isOnLine(p1, p2, x, y, c)) continue;
            return true;
        }
        return false;
    }
}

