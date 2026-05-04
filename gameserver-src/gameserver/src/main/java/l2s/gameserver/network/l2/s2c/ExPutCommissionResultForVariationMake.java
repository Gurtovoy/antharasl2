package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPutCommissionResultForVariationMake
extends L2GameServerPacket {
    private int _gemstoneObjId;
    private int _unk1;
    private int _unk3;
    private long _gemstoneCount;
    private long _unk2;

    public ExPutCommissionResultForVariationMake(int gemstoneObjId, long count) {
        this._gemstoneObjId = gemstoneObjId;
        this._unk1 = 1;
        this._gemstoneCount = count;
        this._unk2 = 1L;
        this._unk3 = 1;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._gemstoneObjId);
        this.writeD(this._unk1);
        this.writeQ(this._gemstoneCount);
        this.writeQ(this._unk2);
        this.writeD(this._unk3);
    }
}

