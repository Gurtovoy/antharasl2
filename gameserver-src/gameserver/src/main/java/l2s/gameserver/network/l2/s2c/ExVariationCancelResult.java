package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExVariationCancelResult
extends L2GameServerPacket {
    private int _closeWindow = 1;
    private int _unk1;

    public ExVariationCancelResult(int result) {
        this._unk1 = result;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._unk1);
        this.writeD(this._closeWindow);
    }
}

