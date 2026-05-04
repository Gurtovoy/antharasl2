/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeEmblem
extends L2GameServerPacket {
    private int _clanId;
    private int _crestId;
    private int _crestPart;
    private int _totalSize;
    private byte[] _data;

    public ExPledgeEmblem(int clanId, int crestId, int crestPart, int totalSize, byte[] data) {
        this._clanId = clanId;
        this._crestId = crestId;
        this._crestPart = crestPart;
        this._totalSize = totalSize;
        this._data = data;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(Config.REQUEST_ID);
        this.writeD(this._clanId);
        this.writeD(this._crestId);
        this.writeD(this._crestPart);
        this.writeD(this._totalSize);
        this.writeD(this._data.length);
        this.writeB(this._data);
    }
}

