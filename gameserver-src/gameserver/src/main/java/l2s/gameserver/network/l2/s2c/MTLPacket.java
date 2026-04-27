/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.Log;

public class MTLPacket
extends L2GameServerPacket {
    private int _objectId;
    private Location _current;
    private Location _destination;

    public MTLPacket(Creature cha) {
        this._objectId = cha.getObjectId();
        this._current = cha.getLoc();
        this._destination = cha.getMovement().getDestination();
        if (this._destination == null) {
            Log.debug("MTLPacket: desc is null, but moving. L2Character: " + cha.getObjectId() + ":" + cha.getName() + "; Loc: " + this._current);
            this._destination = this._current;
        }
    }

    public MTLPacket(int objectId, Location from, Location to) {
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

