/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPutEnchantSupportItemResult
extends L2GameServerPacket {
    public static final L2GameServerPacket FAIL = new ExPutEnchantSupportItemResult(1);
    public static final L2GameServerPacket SUCCESS = new ExPutEnchantSupportItemResult(1);
    private int _result;

    public ExPutEnchantSupportItemResult(int result) {
        this._result = result;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
    }
}

