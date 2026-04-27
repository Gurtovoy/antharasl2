/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class TargetSelectedPacket
extends L2GameServerPacket {
    private int _objectId;
    private int _targetId;
    private Location _loc;

    public TargetSelectedPacket(int objectId, int targetId, Location loc) {
        this._objectId = objectId;
        this._targetId = targetId;
        this._loc = loc;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._targetId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(0);
    }
}

