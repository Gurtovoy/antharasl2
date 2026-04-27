/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class VehicleInfoPacket
extends L2GameServerPacket {
    private int _boatObjectId;
    private Location _loc;

    public VehicleInfoPacket(Boat boat) {
        this._boatObjectId = boat.getBoatId();
        this._loc = boat.getLoc();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._boatObjectId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(this._loc.h);
    }
}

