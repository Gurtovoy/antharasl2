/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AutoAttackStartPacket
extends L2GameServerPacket {
    private int _targetId;

    public AutoAttackStartPacket(int targetId) {
        this._targetId = targetId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._targetId);
    }
}

