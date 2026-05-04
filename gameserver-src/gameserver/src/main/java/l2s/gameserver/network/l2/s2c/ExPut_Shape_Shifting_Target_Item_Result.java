/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPut_Shape_Shifting_Target_Item_Result
extends L2GameServerPacket {
    public static L2GameServerPacket FAIL = new ExPut_Shape_Shifting_Target_Item_Result(0, 0L);
    public static int SUCCESS_RESULT = 1;
    private final int _resultId;
    private final long _price;

    public ExPut_Shape_Shifting_Target_Item_Result(int resultId, long price) {
        this._resultId = resultId;
        this._price = price;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._resultId);
        this.writeQ(this._price);
    }
}

