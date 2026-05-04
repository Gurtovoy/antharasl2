package l2s.commons.geometry;

import java.util.ArrayList;
import l2s.commons.geometry.AbstractShape;
import l2s.commons.geometry.CoordsConverter;
import l2s.commons.geometry.GeometryUtils;
import l2s.commons.geometry.Point2D;

public class Circle
extends AbstractShape {
    protected final Point2D[] points;
    protected final Point2D center;
    protected final int r;

    public Circle(Point2D center, int radius) {
        this.center = center;
        this.r = radius;
        this.min.x = center.x - this.r;
        this.max.x = center.x + this.r;
        this.min.y = center.y - this.r;
        this.max.y = center.y + this.r;
        ArrayList<Point2D> points = new ArrayList<Point2D>();
        for (int deegre = 0; deegre <= 360; deegre += 36) {
            double radians = Math.toRadians(deegre);
            int x = (int)((double)center.getX() - (double)this.r * Math.sin(radians));
            int y = (int)((double)center.getY() + (double)this.r * Math.cos(radians));
            points.add(new Point2D(x, y));
        }
        this.points = points.toArray(new Point2D[points.size()]);
    }

    public Circle(int x, int y, int radius) {
        this(new Point2D(x, y), radius);
    }

    @Override
    public Circle setZmax(int z) {
        this.max.z = z;
        return this;
    }

    @Override
    public Circle setZmin(int z) {
        this.min.z = z;
        return this;
    }

    @Override
    public boolean isInside(int x, int y, CoordsConverter c) {
        return (int)Math.pow(x - c.convertX(this.center.x), 2.0) + (int)Math.pow(y - c.convertY(this.center.y), 2.0) <= (int)Math.pow(c.convertDistance(this.r), 2.0);
    }

    @Override
    public boolean isOnPerimeter(int x, int y, CoordsConverter c) {
        return (int)Math.pow(x - c.convertX(this.center.x), 2.0) + (int)Math.pow(y - c.convertY(this.center.y), 2.0) == (int)Math.pow(c.convertDistance(this.r), 2.0);
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        sb.append(this.center).append("{ radius: ").append(this.r).append("}");
        sb.append("]");
        return sb.toString();
    }

    @Override
    public Point2D getCenter() {
        return this.center;
    }

    @Override
    public Point2D getNearestPoint(int x, int y) {
        return GeometryUtils.getNearestPointOnCircle(this.center, this.r, x, y);
    }

    @Override
    public int getRadius() {
        return this.r;
    }

    @Override
    public Point2D[] getPoints() {
        return this.points;
    }
}

