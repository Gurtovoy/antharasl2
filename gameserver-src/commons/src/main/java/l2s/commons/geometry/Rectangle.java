/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.geometry;

import l2s.commons.geometry.AbstractShape;
import l2s.commons.geometry.CoordsConverter;
import l2s.commons.geometry.GeometryUtils;
import l2s.commons.geometry.Point2D;

public class Rectangle
extends AbstractShape {
    protected final Point2D[] points = new Point2D[4];
    protected final int radius;

    public Rectangle(int x1, int y1, int x2, int y2) {
        this.min.x = Math.min(x1, x2);
        this.min.y = Math.min(y1, y2);
        this.max.x = Math.max(x1, x2);
        this.max.y = Math.max(y1, y2);
        this.points[0] = new Point2D(this.min.x, this.min.y);
        this.points[1] = new Point2D(this.min.x, this.max.y);
        this.points[2] = new Point2D(this.max.x, this.max.y);
        this.points[3] = new Point2D(this.max.x, this.min.y);
        int r = 0;
        Point2D center = this.getCenter();
        for (Point2D point : this.points) {
            r = Math.max(r, GeometryUtils.calculateDistance(center, point));
        }
        this.radius = r;
    }

    @Override
    public Rectangle setZmax(int z) {
        this.max.z = z;
        return this;
    }

    @Override
    public Rectangle setZmin(int z) {
        this.min.z = z;
        return this;
    }

    @Override
    public boolean isInside(int x, int y, CoordsConverter c) {
        return x >= c.convertX(this.min.x) && x <= c.convertX(this.max.x) && y >= c.convertY(this.min.y) && y <= c.convertY(this.max.y);
    }

    @Override
    public boolean isOnPerimeter(int x, int y, CoordsConverter c) {
        return GeometryUtils.isOnPolygonPerimeter(this.points, x, y, c);
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        sb.append(this.min).append(", ").append(this.max);
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

