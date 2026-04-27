/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.geometry;

import l2s.commons.geometry.CoordsConverter;
import l2s.commons.geometry.Point2D;

public interface Shape {
    default public boolean isInside(int x, int y) {
        return this.isInside(x, y, CoordsConverter.DEFAULT_CONVERTER);
    }

    public boolean isInside(int var1, int var2, CoordsConverter var3);

    default public boolean isInside(int x, int y, int z) {
        return this.isInside(x, y, z, CoordsConverter.DEFAULT_CONVERTER);
    }

    public boolean isInside(int var1, int var2, int var3, CoordsConverter var4);

    default public boolean isOnPerimeter(int x, int y) {
        return this.isOnPerimeter(x, y, CoordsConverter.DEFAULT_CONVERTER);
    }

    public boolean isOnPerimeter(int var1, int var2, CoordsConverter var3);

    default public boolean isOnPerimeter(int x, int y, int z) {
        return this.isOnPerimeter(x, y, z, CoordsConverter.DEFAULT_CONVERTER);
    }

    public boolean isOnPerimeter(int var1, int var2, int var3, CoordsConverter var4);

    public int getXmax();

    public int getXmin();

    public int getYmax();

    public int getYmin();

    public int getZmax();

    public int getZmin();

    public Point2D getCenter();

    public Point2D getNearestPoint(int var1, int var2);

    public int getRadius();

    public Point2D[] getPoints();
}

