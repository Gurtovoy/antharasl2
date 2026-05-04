/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPutIntensiveResultForVariationMake
extends L2GameServerPacket {
    private int _refinerItemObjId;
    private int _lifestoneItemId;
    private int _gemstoneItemId;
    private int _unk;
    private long _gemstoneCount;

    public ExPutIntensiveResultForVariationMake(int refinerItemObjId, int lifeStoneId, int gemstoneItemId, long gemstoneCount) {
        this._refinerItemObjId = refinerItemObjId;
        this._lifestoneItemId = lifeStoneId;
        this._gemstoneItemId = gemstoneItemId;
        this._gemstoneCount = gemstoneCount;
        this._unk = 1;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._refinerItemObjId);
        this.writeD(this._lifestoneItemId);
        this.writeD(this._gemstoneItemId);
        this.writeQ(this._gemstoneCount);
        this.writeD(this._unk);
    }
}

