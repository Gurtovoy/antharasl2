/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class EarthQuakePacket
extends L2GameServerPacket {
    private Location _loc;
    private int _intensity;
    private int _duration;

    public EarthQuakePacket(Location loc, int intensity, int duration) {
        this._loc = loc;
        this._intensity = intensity;
        this._duration = duration;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(this._intensity);
        this.writeD(this._duration);
        this.writeD(0);
    }
}

