/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExResponseCommissionDelete
extends L2GameServerPacket {
    @Override
    protected void writeImpl() {
        this.writeD(0);
        this.writeD(0);
        this.writeQ(0L);
    }
}

