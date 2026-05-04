package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class MoveToLocationInVehiclePacket
extends L2GameServerPacket {
    private int _playerObjectId;
    private int _boatObjectId;
    private Location _origin;
    private Location _destination;

    public MoveToLocationInVehiclePacket(Player cha, Boat boat, Location origin, Location destination) {
        this._playerObjectId = cha.getObjectId();
        this._boatObjectId = boat.getBoatId();
        this._origin = origin;
        this._destination = destination;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playerObjectId);
        this.writeD(this._boatObjectId);
        this.writeD(this._destination.x);
        this.writeD(this._destination.y);
        this.writeD(this._destination.z);
        this.writeD(this._origin.x);
        this.writeD(this._origin.y);
        this.writeD(this._origin.z);
    }
}

