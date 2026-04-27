/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class WareHouseDonePacket
extends L2GameServerPacket {
    @Override
    protected void writeImpl() {
        this.writeD(0);
    }
}

