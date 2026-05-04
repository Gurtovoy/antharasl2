/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AllianceCrestPacket
extends L2GameServerPacket {
    private int _crestId;
    private byte[] _data;

    public AllianceCrestPacket(int crestId, byte[] data) {
        this._crestId = crestId;
        this._data = data;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(Config.REQUEST_ID);
        this.writeD(this._crestId);
        this.writeD(this._data.length);
        this.writeB(this._data);
    }
}

