package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class ExEnchantFail
extends L2GameServerPacket {
    public static final L2GameServerPacket STATIC = new ExEnchantFail(0, 0);
    private final int _itemOne;
    private final int _itemTwo;

    public ExEnchantFail(int itemOne, int itemTwo) {
        this._itemOne = itemOne;
        this._itemTwo = itemTwo;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._itemOne);
        this.writeD(this._itemTwo);
    }
}

