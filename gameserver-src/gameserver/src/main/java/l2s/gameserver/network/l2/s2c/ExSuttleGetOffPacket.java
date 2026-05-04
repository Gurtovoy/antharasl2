package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.entity.boat.Shuttle;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExSuttleGetOffPacket
extends L2GameServerPacket {
    private int _playerObjectId;
    private int _shuttleId;
    private Location _loc;

    public ExSuttleGetOffPacket(Playable cha, Shuttle shuttle, Location loc) {
        this._playerObjectId = cha.getObjectId();
        this._shuttleId = shuttle.getBoatId();
        this._loc = loc;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playerObjectId);
        this.writeD(this._shuttleId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
    }
}

