/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExUserInfoInvenWeight
extends L2GameServerPacket {
    private final int _objectId;
    private final int _currentLoad;
    private final int _maxLoad;

    public ExUserInfoInvenWeight(Player player) {
        this._objectId = player.getObjectId();
        this._currentLoad = player.getCurrentLoad();
        this._maxLoad = player.getMaxLoad();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._currentLoad);
        this.writeD(this._maxLoad);
    }
}

