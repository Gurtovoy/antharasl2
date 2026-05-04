/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.entity.boat.Shuttle;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExSuttleGetOnPacket
extends L2GameServerPacket {
    private int _playerObjectId;
    private int _shuttleId;
    private Location _loc;

    public ExSuttleGetOnPacket(Playable cha, Shuttle shuttle, Location loc) {
        this._playerObjectId = cha.getObjectId();
        this._shuttleId = shuttle.getBoatId();
        this._loc = loc;
        if (this._loc == null) {
            this._loc = cha.getLoc();
        }
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

