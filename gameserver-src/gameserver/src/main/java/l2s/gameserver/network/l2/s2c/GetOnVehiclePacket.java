package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class GetOnVehiclePacket
extends L2GameServerPacket {
    private int _playerObjectId;
    private int _boatObjectId;
    private Location _loc;

    public GetOnVehiclePacket(Player activeChar, Boat boat, Location loc) {
        this._loc = loc;
        this._playerObjectId = activeChar.getObjectId();
        this._boatObjectId = boat.getBoatId();
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

