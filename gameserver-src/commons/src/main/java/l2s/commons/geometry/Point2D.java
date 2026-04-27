/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.geometry;

public class Point2D
implements Cloneable {
    public static final Point2D[] EMPTY_ARRAY = new Point2D[0];
    public int x;
    public int y;

    public Point2D() {
    }

    public Point2D(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public Point2D clone() {
        return new Point2D(this.x, this.y);
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (o == null) {
            return false;
        }
        if (o.getClass() != this.getClass()) {
            return false;
        }
        return this.equals((Point2D)o);
    }

    public int hashCode() {
        int hash = this.x;
        hash = 43 * hash + this.y;
        return hash;
    }

    public boolean equals(Point2D p) {
        return this.equals(p.x, p.y);
    }

    public boolean equals(int x, int y) {
        return this.x == x && this.y == y;
    }

    public int getX() {
        return this.x;
    }

    public int getY() {
        return this.y;
    }

    public String toString() {
        return "[x: " + this.x + " y: " + this.y + "]";
    }
}

