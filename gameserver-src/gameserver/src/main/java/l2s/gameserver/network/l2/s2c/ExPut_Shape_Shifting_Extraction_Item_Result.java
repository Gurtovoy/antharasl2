/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPut_Shape_Shifting_Extraction_Item_Result
extends L2GameServerPacket {
    public static L2GameServerPacket FAIL = new ExPut_Shape_Shifting_Extraction_Item_Result(0);
    public static L2GameServerPacket SUCCESS = new ExPut_Shape_Shifting_Extraction_Item_Result(1);
    private final int _result;

    public ExPut_Shape_Shifting_Extraction_Item_Result(int result) {
        this._result = result;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
    }
}

