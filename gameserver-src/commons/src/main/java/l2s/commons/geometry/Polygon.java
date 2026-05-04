package l2s.commons.geometry;

import l2s.commons.geometry.AbstractShape;
import l2s.commons.geometry.CoordsConverter;
import l2s.commons.geometry.GeometryUtils;
import l2s.commons.geometry.Point2D;
import l2s.commons.lang.ArrayUtils;

public class Polygon
extends AbstractShape {
    protected Point2D[] points = Point2D.EMPTY_ARRAY;
    protected int radius = 0;

    public Polygon add(int x, int y) {
        this.add(new Point2D(x, y));
        return this;
    }

    public Polygon add(Point2D p) {
        if (this.points.length == 0) {
            this.min.y = p.y;
            this.min.x = p.x;
            this.max.x = p.x;
            this.max.y = p.y;
        } else {
            this.min.y = Math.min(this.min.y, p.y);
            this.min.x = Math.min(this.min.x, p.x);
            this.max.x = Math.max(this.max.x, p.x);
            this.max.y = Math.max(this.max.y, p.y);
        }
        this.points = ArrayUtils.add(this.points, p);
        this.radius = Math.max(this.radius, GeometryUtils.calculateDistance(this.getCenter(), p));
        return this;
    }

    @Override
    public Polygon setZmax(int z) {
        this.max.z = z;
        return this;
    }

    @Override
    public Polygon setZmin(int z) {
        this.min.z = z;
        return this;
    }

    /*
     * Unable to fully structure code
     */
    @Override
    public boolean isInside(int x, int y, CoordsConverter c) {
        if (x < c.convertX(this.min.x) || x > c.convertX(this.max.x) || y < c.convertY(this.min.y) || y > c.convertY(this.max.y)) {
            return false;
        }
        int hits = 0;
        int npoints = this.points.length;
        Point2D last = this.points[npoints - 1];
        for (int i = 0; i < npoints; ++i) {
            Point2D cur = this.points[i];
            int leftx;
            int test1;
            int test2;
            block8: {
                block11: {
                    block12: {
                        block10: {
                            block9: {
                                if (c.convertY(cur.y) == c.convertY(last.y)) break block8;
                                if (c.convertX(cur.x) >= c.convertX(last.x)) break block9;
                                if (x >= c.convertX(last.x)) break block8;
                                leftx = c.convertX(cur.x);
                                break block10;
                            }
                            if (x >= c.convertX(cur.x)) break block8;
                            leftx = c.convertX(last.x);
                        }
                        if (c.convertY(cur.y) >= c.convertY(last.y)) break block11;
                        if (y < c.convertY(cur.y) || y >= c.convertY(last.y)) break block8;
                        if (x >= leftx) break block12;
                        ++hits;
                        break block8;
                    }
                    test1 = x - c.convertX(cur.x);
                    test2 = y - c.convertY(cur.y);
                    if (test1 < test2 / (double)(c.convertY(last.y) - c.convertY(cur.y)) * (double)(c.convertX(last.x) - c.convertX(cur.x))) {
                        ++hits;
                    }
                }
                if (y < c.convertY(last.y) || y >= c.convertY(cur.y)) break block8;
                if (x < leftx) {
                    ++hits;
                } else {
                    test1 = x - c.convertX(last.x);
                    test2 = y - c.convertY(last.y);
                    if (test1 < test2 / (double)(c.convertY(last.y) - c.convertY(cur.y)) * (double)(c.convertX(last.x) - c.convertX(cur.x))) {
                        ++hits;
                    }
                }
            }
            last = cur;
        }
        return (hits & 1) != 0;
    }

    @Override
    public boolean isOnPerimeter(int x, int y, CoordsConverter c) {
        return GeometryUtils.isOnPolygonPerimeter(this.points, x, y, c);
    }

    public boolean validate() {
        if (this.points.length < 3) {
            return false;
        }
        if (this.points.length > 3) {
            for (int i = 1; i < this.points.length; ++i) {
                int ii = i + 1 < this.points.length ? i + 1 : 0;
                for (int n = i; n < this.points.length; ++n) {
                    int nn;
                    if (Math.abs(n - i) <= 1) continue;
                    int n2 = nn = n + 1 < this.points.length ? n + 1 : 0;
                    if (!GeometryUtils.checkIfLineSegementsIntersects(this.points[i], this.points[ii], this.points[n], this.points[nn])) continue;
                    return false;
                }
            }
        }
        return true;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < this.points.length; ++i) {
            sb.append(this.points[i]);
            if (i >= this.points.length - 1) continue;
            sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    @Override
    public Point2D getCenter() {
        return GeometryUtils.getLineCenter(this.min.x, this.min.y, this.max.x, this.max.y);
    }

    @Override
    public Point2D getNearestPoint(int x, int y) {
        return GeometryUtils.getNearestPointOnPolygon(this.points, x, y);
    }

    @Override
    public int getRadius() {
        return this.radius;
    }

    @Override
    public Point2D[] getPoints() {
        return this.points;
    }
}

