/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExSetPartyLooting
extends L2GameServerPacket {
    private int _result;
    private int _mode;

    public ExSetPartyLooting(int result, int mode) {
        this._result = result;
        this._mode = mode;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
        this.writeD(this._mode);
    }
}

