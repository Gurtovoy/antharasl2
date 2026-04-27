/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExRaidServerInfo
extends L2GameServerPacket {
    @Override
    protected final void writeImpl() {
        this.writeC(0);
        this.writeC(0);
    }
}

