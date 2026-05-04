/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AutoAttackStopPacket
extends L2GameServerPacket {
    private int _targetId;

    public AutoAttackStopPacket(int targetId) {
        this._targetId = targetId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._targetId);
    }
}

