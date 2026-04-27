/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFishingStartPacket
extends L2GameServerPacket {
    private int _charObjId;
    private Location _loc;
    private int _fishType;
    private boolean _isNightLure;

    public ExFishingStartPacket(Creature character, int fishType, Location loc, boolean isNightLure) {
        this._charObjId = character.getObjectId();
        this._fishType = fishType;
        this._loc = loc;
        this._isNightLure = isNightLure;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._charObjId);
        this.writeD(this._fishType);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeC(this._isNightLure ? 1 : 0);
        this.writeC(1);
    }
}

