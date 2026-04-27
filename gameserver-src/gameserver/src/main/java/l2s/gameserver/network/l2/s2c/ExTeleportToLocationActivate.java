/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExTeleportToLocationActivate
extends L2GameServerPacket {
    private int _targetId;
    private Location _loc;

    public ExTeleportToLocationActivate(GameObject cha, Location loc) {
        this._targetId = cha.getObjectId();
        this._loc = loc;
    }

    public ExTeleportToLocationActivate(GameObject cha, int x, int y, int z) {
        this._targetId = cha.getObjectId();
        this._loc = new Location(x, y, z, cha.getHeading());
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._targetId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(0);
        this.writeD(this._loc.h);
        this.writeD(0);
    }
}

