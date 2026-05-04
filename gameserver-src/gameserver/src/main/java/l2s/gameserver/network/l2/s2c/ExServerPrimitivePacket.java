/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.awt.Color;
import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExServerPrimitivePacket
extends L2GameServerPacket {
    private final String _name;
    private final int _x;
    private final int _y;
    private final int _z;
    private final List<Point> _points = new ArrayList<Point>();
    private final List<Line> _lines = new ArrayList<Line>();

    public ExServerPrimitivePacket(String name, int x, int y, int z) {
        this._name = name;
        this._x = x;
        this._y = y;
        this._z = z;
    }

    public void addPoint(String name, int color, boolean isNameColored, int x, int y, int z) {
        this._points.add(new Point(name, color, isNameColored, x, y, z));
    }

    public void addPoint(int color, int x, int y, int z) {
        this.addPoint("", color, false, x, y, z);
    }

    public void addPoint(String name, Color color, boolean isNameColored, int x, int y, int z) {
        this.addPoint(name, color.getRGB(), isNameColored, x, y, z);
    }

    public void addPoint(Color color, int x, int y, int z) {
        this.addPoint("", color, false, x, y, z);
    }

    public void addLine(String name, int color, boolean isNameColored, int x, int y, int z, int x2, int y2, int z2) {
        this._lines.add(new Line(name, color, isNameColored, x, y, z, x2, y2, z2));
    }

    public void addLine(int color, int x, int y, int z, int x2, int y2, int z2) {
        this.addLine("", color, false, x, y, z, x2, y2, z2);
    }

    public void addLine(String name, Color color, boolean isNameColored, int x, int y, int z, int x2, int y2, int z2) {
        this.addLine(name, color.getRGB(), isNameColored, x, y, z, x2, y2, z2);
    }

    public void addLine(Color color, int x, int y, int z, int x2, int y2, int z2) {
        this.addLine("", color, false, x, y, z, x2, y2, z2);
    }

    @Override
    protected void writeImpl() {
        int color;
        this.writeS(this._name);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
        this.writeD(65535);
        this.writeD(65535);
        this.writeD(this._points.size() + this._lines.size());
        for (Point point : this._points) {
            this.writeC(1);
            this.writeS(point.getName());
            color = point.getColor();
            this.writeD(color >> 16 & 0xFF);
            this.writeD(color >> 8 & 0xFF);
            this.writeD(color & 0xFF);
            this.writeD(point.isNameColored() ? 1 : 0);
            this.writeD(point.getX());
            this.writeD(point.getY());
            this.writeD(point.getZ());
        }
        for (Line line : this._lines) {
            this.writeC(2);
            this.writeS(line.getName());
            color = line.getColor();
            this.writeD(color >> 16 & 0xFF);
            this.writeD(color >> 8 & 0xFF);
            this.writeD(color & 0xFF);
            this.writeD(line.isNameColored() ? 1 : 0);
            this.writeD(line.getX());
            this.writeD(line.getY());
            this.writeD(line.getZ());
            this.writeD(line.getX2());
            this.writeD(line.getY2());
            this.writeD(line.getZ2());
        }
    }

    private static class Line
    extends Point {
        private final int _x2;
        private final int _y2;
        private final int _z2;

        public Line(String name, int color, boolean isNameColored, int x, int y, int z, int x2, int y2, int z2) {
            super(name, color, isNameColored, x, y, z);
            this._x2 = x2;
            this._y2 = y2;
            this._z2 = z2;
        }

        public int getX2() {
            return this._x2;
        }

        public int getY2() {
            return this._y2;
        }

        public int getZ2() {
            return this._z2;
        }
    }

    private static class Point {
        private final String _name;
        private final int _color;
        private final boolean _isNameColored;
        private final int _x;
        private final int _y;
        private final int _z;

        public Point(String name, int color, boolean isNameColored, int x, int y, int z) {
            this._name = name;
            this._color = color;
            this._isNameColored = isNameColored;
            this._x = x;
            this._y = y;
            this._z = z;
        }

        public String getName() {
            return this._name;
        }

        public int getColor() {
            return this._color;
        }

        public boolean isNameColored() {
            return this._isNameColored;
        }

        public int getX() {
            return this._x;
        }

        public int getY() {
            return this._y;
        }

        public int getZ() {
            return this._z;
        }
    }
}

