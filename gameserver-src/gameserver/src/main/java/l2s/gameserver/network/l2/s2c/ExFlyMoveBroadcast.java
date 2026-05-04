/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFlyMoveBroadcast
extends L2GameServerPacket {
    private int _objId;
    private final int _trackId;
    private ILocation _loc;
    private ILocation _destLoc;

    public ExFlyMoveBroadcast(Player player, int trackId, ILocation destLoc) {
        this._objId = player.getObjectId();
        this._trackId = trackId;
        this._loc = player;
        this._destLoc = destLoc;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objId);
        this.writeD(1);
        this.writeD(this._trackId);
        this.writeD(this._loc.getX());
        this.writeD(this._loc.getY());
        this.writeD(this._loc.getZ());
        this.writeD(0);
        this.writeD(this._destLoc.getX());
        this.writeD(this._destLoc.getY());
        this.writeD(this._destLoc.getZ());
    }
}

