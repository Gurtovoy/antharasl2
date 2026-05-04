package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class GetOffVehiclePacket
extends L2GameServerPacket {
    private int _playerObjectId;
    private int _boatObjectId;
    private Location _loc;

    public GetOffVehiclePacket(Player cha, Boat boat, Location loc) {
        this._playerObjectId = cha.getObjectId();
        this._boatObjectId = boat.getBoatId();
        this._loc = loc;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playerObjectId);
        this.writeD(this._boatObjectId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
    }
}

