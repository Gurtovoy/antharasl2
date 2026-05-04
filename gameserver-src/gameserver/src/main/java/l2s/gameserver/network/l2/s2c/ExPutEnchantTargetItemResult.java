package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPutEnchantTargetItemResult
extends L2GameServerPacket {
    public static final L2GameServerPacket FAIL = new ExPutEnchantTargetItemResult(0);
    public static final L2GameServerPacket SUCCESS = new ExPutEnchantTargetItemResult(1);
    private int _result;

    public ExPutEnchantTargetItemResult(int result) {
        this._result = result;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
    }
}

