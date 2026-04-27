/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeReceiveUpdatePower
extends L2GameServerPacket {
    private int _privs;

    public PledgeReceiveUpdatePower(int privs) {
        this._privs = privs;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._privs);
    }
}

