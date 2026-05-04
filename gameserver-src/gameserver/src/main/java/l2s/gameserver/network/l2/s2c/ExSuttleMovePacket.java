package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.boat.Shuttle;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExSuttleMovePacket
extends L2GameServerPacket {
    private final Shuttle _shuttle;
    private final Location _destination;

    public ExSuttleMovePacket(Shuttle shuttle) {
        this._shuttle = shuttle;
        this._destination = shuttle.getMovement().getDestination();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._shuttle.getBoatId());
        this.writeD(this._shuttle.getMoveSpeed());
        this.writeD(this._shuttle.getRotationSpeed());
        this.writeD(this._destination.getX());
        this.writeD(this._destination.getY());
        this.writeD(this._destination.getZ());
    }
}

