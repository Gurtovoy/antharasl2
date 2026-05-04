/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class GMHidePacket
extends L2GameServerPacket {
    private final int obj_id;

    public GMHidePacket(int id) {
        this.obj_id = id;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this.obj_id);
    }
}

