/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeCrestPacket
extends L2GameServerPacket {
    private int _crestId;
    private int _crestSize;
    private byte[] _data;

    public PledgeCrestPacket(int crestId, byte[] data) {
        this._crestId = crestId;
        this._data = data;
        this._crestSize = this._data.length;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(Config.REQUEST_ID);
        this.writeD(this._crestId);
        this.writeD(this._crestSize);
        this.writeB(this._data);
    }
}

