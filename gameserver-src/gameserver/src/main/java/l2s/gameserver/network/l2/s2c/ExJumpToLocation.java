/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExJumpToLocation
extends L2GameServerPacket {
    private int _objectId;
    private Location _current;
    private Location _destination;

    public ExJumpToLocation(Creature cha) {
        this._objectId = cha.getObjectId();
        this._current = cha.getLoc();
        this._destination = cha.getLoc();
    }

    public ExJumpToLocation(int objectId, Location from, Location to) {
        this._objectId = objectId;
        this._current = from;
        this._destination = to;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._destination.x);
        this.writeD(this._destination.y);
        this.writeD(this._destination.z);
        this.writeD(this._current.x);
        this.writeD(this._current.y);
        this.writeD(this._current.z);
    }
}

