/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.commons.geometry.Point2D;
import l2s.commons.geometry.Shape;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowTerritory
extends L2GameServerPacket {
    private final Shape _shape;

    public ExShowTerritory(Shape shape) {
        this._shape = shape;
    }

    @Override
    protected void writeImpl() {
        Point2D[] points = this._shape.getPoints();
        this.writeD(points.length);
        this.writeD(this._shape.getZmin());
        this.writeD(this._shape.getZmax());
        for (Point2D point : points) {
            this.writeD(point.getX());
            this.writeD(point.getY());
        }
    }
}

