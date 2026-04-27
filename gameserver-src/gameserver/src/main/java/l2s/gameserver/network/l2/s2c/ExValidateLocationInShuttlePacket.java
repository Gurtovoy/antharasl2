/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExValidateLocationInShuttlePacket
extends L2GameServerPacket {
    private int _playerObjectId;
    private int _shuttleId;
    private Location _loc;

    public ExValidateLocationInShuttlePacket(Player cha) {
        this._playerObjectId = cha.getObjectId();
        this._shuttleId = cha.getBoat().getBoatId();
        this._loc = cha.getInBoatPosition();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playerObjectId);
        this.writeD(this._shuttleId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(this._loc.h);
    }
}

