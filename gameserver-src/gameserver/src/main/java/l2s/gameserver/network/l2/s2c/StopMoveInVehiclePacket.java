/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class StopMoveInVehiclePacket
extends L2GameServerPacket {
    private int _boatObjectId;
    private int _playerObjectId;
    private int _heading;
    private Location _loc;

    public StopMoveInVehiclePacket(Player player) {
        this._boatObjectId = player.getBoat().getBoatId();
        this._playerObjectId = player.getObjectId();
        this._loc = player.getInBoatPosition();
        this._heading = player.getHeading();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playerObjectId);
        this.writeD(this._boatObjectId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(this._heading);
    }
}

