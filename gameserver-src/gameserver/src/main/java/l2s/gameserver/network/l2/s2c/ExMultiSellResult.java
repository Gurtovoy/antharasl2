package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExMultiSellResult
extends L2GameServerPacket {
    public static final L2GameServerPacket SUCCESS = new ExMultiSellResult();
    private final boolean _success;
    private final int _unk1;
    private final int _unk2;

    private ExMultiSellResult() {
        this._success = true;
        this._unk1 = 0;
        this._unk2 = 0;
    }

    public ExMultiSellResult(int unk1, int unk2) {
        this._success = false;
        this._unk1 = unk1;
        this._unk2 = unk2;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._success);
        this.writeD(this._unk1);
        this.writeD(this._unk2);
    }
}

