package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class VersionCheckPacket
extends L2GameServerPacket {
    private byte[] _key;

    public VersionCheckPacket(byte[] key) {
        this._key = key;
    }

    @Override
    public void writeImpl() {
        if (this._key == null || this._key.length == 0) {
            this.writeC(0);
            return;
        }
        this.writeC(1);
        for (int i = 0; i < 8; ++i) {
            this.writeC(this._key[i]);
        }
        this.writeD(1);
        this.writeD(Config.REQUEST_ID);
        this.writeC(1);
        this.writeD(0);
        this.writeC(1);
        this.writeC(0);
    }
}

