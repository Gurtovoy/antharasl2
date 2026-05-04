/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBlockDefailInfo
extends L2GameServerPacket {
    private final String _blockName;
    private final String _blockMemo;

    public ExBlockDefailInfo(String name, String memo) {
        this._blockName = name;
        this._blockMemo = memo;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._blockName);
        this.writeS(this._blockMemo);
    }
}

