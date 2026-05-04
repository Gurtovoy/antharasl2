/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBlockRemoveResult
extends L2GameServerPacket {
    private final String _blockName;

    public ExBlockRemoveResult(String name) {
        this._blockName = name;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(1);
        this.writeS(this._blockName);
    }
}

