package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class VehicleDeparturePacket
extends L2GameServerPacket {
    private int _moveSpeed;
    private int _rotationSpeed;
    private int _boatObjId;
    private Location _loc;

    public VehicleDeparturePacket(Boat boat) {
        this._boatObjId = boat.getBoatId();
        this._moveSpeed = boat.getMoveSpeed();
        this._rotationSpeed = boat.getRotationSpeed();
        this._loc = boat.getMovement().getDestination();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._boatObjId);
        this.writeD(this._moveSpeed);
        this.writeD(this._rotationSpeed);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
    }
}

