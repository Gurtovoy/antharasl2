package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class VehicleStartPacket
extends L2GameServerPacket {
    private int _objectId;
    private int _state;

    public VehicleStartPacket(Boat boat) {
        this._objectId = boat.getBoatId();
        this._state = boat.getRunState();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._state);
    }
}

