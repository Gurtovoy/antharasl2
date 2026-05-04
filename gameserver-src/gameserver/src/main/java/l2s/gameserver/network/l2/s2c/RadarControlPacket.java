/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RadarControlPacket
extends L2GameServerPacket {
    private int _x;
    private int _y;
    private int _z;
    private int _type;
    private int _showRadar;

    public RadarControlPacket(int showRadar, int type, Location loc) {
        this(showRadar, type, loc.x, loc.y, loc.z);
    }

    public RadarControlPacket(int showRadar, int type, int x, int y, int z) {
        this._showRadar = showRadar;
        this._type = type;
        this._x = x;
        this._y = y;
        this._z = z;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._showRadar);
        this.writeD(this._type);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
    }
}

