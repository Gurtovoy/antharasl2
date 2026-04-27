/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShape_Shifting_Result
extends L2GameServerPacket {
    public static L2GameServerPacket FAIL = new ExShape_Shifting_Result(0, 0, 0, -1);
    public static int SUCCESS_RESULT = 1;
    private final int _result;
    private final int _targetItemId;
    private final int _extractItemId;
    private final int _period;

    public ExShape_Shifting_Result(int result, int targetItemId, int extractItemId, int period) {
        this._result = result;
        this._targetItemId = targetItemId;
        this._extractItemId = extractItemId;
        this._period = period;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
        this.writeD(this._targetItemId);
        this.writeD(this._extractItemId);
        this.writeD(this._period);
    }
}

