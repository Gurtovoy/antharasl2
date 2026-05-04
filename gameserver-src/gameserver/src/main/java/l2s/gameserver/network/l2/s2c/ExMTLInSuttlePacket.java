/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Shuttle;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExMTLInSuttlePacket
extends L2GameServerPacket {
    private int _playableObjectId;
    private int _shuttleId;
    private Location _origin;
    private Location _destination;

    public ExMTLInSuttlePacket(Player player, Shuttle shuttle, Location origin, Location destination) {
        this._playableObjectId = player.getObjectId();
        this._shuttleId = shuttle.getBoatId();
        this._origin = origin;
        this._destination = destination;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playableObjectId);
        this.writeD(this._shuttleId);
        this.writeD(this._destination.x);
        this.writeD(this._destination.y);
        this.writeD(this._destination.z);
        this.writeD(this._origin.x);
        this.writeD(this._origin.y);
        this.writeD(this._origin.z);
    }
}

