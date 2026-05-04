/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowDominionRegistry
extends L2GameServerPacket {
    @Override
    protected void writeImpl() {
        this.writeD(0);
        this.writeS("");
        this.writeS("");
        this.writeS("");
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(1);
        this.writeD(0);
    }
}

