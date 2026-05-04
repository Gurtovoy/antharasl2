/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExTodoListInzone
extends L2GameServerPacket {
    @Override
    protected final void writeImpl() {
        int instancesCount = 0;
        this.writeH(0);
        for (int i = 0; i < instancesCount; ++i) {
            this.writeC(0);
            this.writeS("");
            this.writeS("");
            this.writeH(0);
            this.writeH(0);
            this.writeH(0);
            this.writeH(0);
            this.writeC(0);
            this.writeC(0);
        }
    }
}

