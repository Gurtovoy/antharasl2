/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RidePacket
extends L2GameServerPacket {
    private int _mountType;
    private int _id;
    private int _rideClassID;
    private Location _loc;

    public RidePacket(Player cha) {
        this._id = cha.getObjectId();
        this._mountType = cha.getMountType().ordinal();
        this._rideClassID = cha.getMountNpcId() + 1000000;
        this._loc = cha.getLoc();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._id);
        this.writeD(this._mountType);
        this.writeD(this._mountType);
        this.writeD(this._rideClassID);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
    }
}

