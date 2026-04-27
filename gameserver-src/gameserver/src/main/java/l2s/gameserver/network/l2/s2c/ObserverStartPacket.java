/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ObserverStartPacket
extends L2GameServerPacket {
    private Location _loc;

    public ObserverStartPacket(Location loc) {
        this._loc = loc;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(0);
        this.writeD(0);
    }
}

