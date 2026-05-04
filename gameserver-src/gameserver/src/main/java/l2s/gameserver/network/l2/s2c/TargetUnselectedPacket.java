/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class TargetUnselectedPacket
extends L2GameServerPacket {
    private int _targetId;
    private Location _loc;

    public TargetUnselectedPacket(GameObject obj) {
        this._targetId = obj.getObjectId();
        this._loc = obj.getLoc();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._targetId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(0);
    }
}

