package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBR_BuyProductPacket
extends L2GameServerPacket {
    public static final L2GameServerPacket RESULT_OK = new ExBR_BuyProductPacket(1);
    public static final L2GameServerPacket RESULT_NOT_ENOUGH_POINTS = new ExBR_BuyProductPacket(-1);
    public static final L2GameServerPacket RESULT_WRONG_PRODUCT = new ExBR_BuyProductPacket(-2);
    public static final L2GameServerPacket RESULT_INVENTORY_FULL = new ExBR_BuyProductPacket(-4);
    public static final L2GameServerPacket RESULT_WRONG_ITEM = new ExBR_BuyProductPacket(-5);
    public static final L2GameServerPacket RESULT_SALE_PERIOD_ENDED = new ExBR_BuyProductPacket(-7);
    public static final L2GameServerPacket RESULT_WRONG_USER_STATE = new ExBR_BuyProductPacket(-9);
    public static final L2GameServerPacket RESULT_WRONG_PRODUCT_ITEM = new ExBR_BuyProductPacket(-10);
    public static final L2GameServerPacket RESULT_WRONG_DAY_OF_WEEK = new ExBR_BuyProductPacket(-12);
    public static final L2GameServerPacket RESULT_WRONG_SALE_PERIOD = new ExBR_BuyProductPacket(-13);
    public static final L2GameServerPacket RESULT_ITEM_WAS_SALED = new ExBR_BuyProductPacket(-14);
    public static final L2GameServerPacket RESULT_RECIPIENT_DOESNT_EXIST = new ExBR_BuyProductPacket(-17);
    public static final L2GameServerPacket RESULT_CAN_NOT_SEND_PACKAGE_TO_YOURSELF = new ExBR_BuyProductPacket(-18);
    public static final L2GameServerPacket RESULT_BLOCKED_YOU_YOU_CANNOT_SEND_MAIL = new ExBR_BuyProductPacket(-21);
    public static final L2GameServerPacket RESULT_NOT_ENOUGH_ADENA = new ExBR_BuyProductPacket(-25);
    public static final L2GameServerPacket RESULT_NOT_ENOUGH_FREE_COINS = new ExBR_BuyProductPacket(-26);
    public static final L2GameServerPacket RESULT_ITEM_LIMITED = new ExBR_BuyProductPacket(-28);
    private final int _result;

    public ExBR_BuyProductPacket(int result) {
        this._result = result;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
    }
}

