/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBR_PresentBuyProductPacket
extends L2GameServerPacket {
    public static final L2GameServerPacket RESULT_OK = new ExBR_PresentBuyProductPacket(1);
    public static final L2GameServerPacket RESULT_NOT_ENOUGH_POINTS = new ExBR_PresentBuyProductPacket(-1);
    public static final L2GameServerPacket RESULT_WRONG_PRODUCT = new ExBR_PresentBuyProductPacket(-2);
    public static final L2GameServerPacket RESULT_INVENTORY_FULL = new ExBR_PresentBuyProductPacket(-4);
    public static final L2GameServerPacket RESULT_WRONG_ITEM = new ExBR_PresentBuyProductPacket(-5);
    public static final L2GameServerPacket RESULT_SALE_PERIOD_ENDED = new ExBR_PresentBuyProductPacket(-7);
    public static final L2GameServerPacket RESULT_WRONG_USER_STATE = new ExBR_PresentBuyProductPacket(-9);
    public static final L2GameServerPacket RESULT_WRONG_PRODUCT_ITEM = new ExBR_PresentBuyProductPacket(-10);
    public static final L2GameServerPacket RESULT_WRONG_DAY_OF_WEEK = new ExBR_PresentBuyProductPacket(-12);
    public static final L2GameServerPacket RESULT_WRONG_SALE_PERIOD = new ExBR_PresentBuyProductPacket(-13);
    public static final L2GameServerPacket RESULT_ITEM_WAS_SALED = new ExBR_PresentBuyProductPacket(-14);
    public static final L2GameServerPacket RESULT_RECIPIENT_DOESNT_EXIST = new ExBR_PresentBuyProductPacket(-17);
    public static final L2GameServerPacket RESULT_CAN_NOT_SEND_PACKAGE_TO_YOURSELF = new ExBR_PresentBuyProductPacket(-18);
    public static final L2GameServerPacket RESULT_BLOCKED_YOU_YOU_CANNOT_SEND_MAIL = new ExBR_PresentBuyProductPacket(-21);
    public static final L2GameServerPacket RESULT_NOT_ENOUGH_ADENA = new ExBR_PresentBuyProductPacket(-25);
    public static final L2GameServerPacket RESULT_NOT_ENOUGH_FREE_COINS = new ExBR_PresentBuyProductPacket(-26);
    public static final L2GameServerPacket RESULT_ITEM_LIMITED = new ExBR_PresentBuyProductPacket(-28);
    private final int _result;

    public ExBR_PresentBuyProductPacket(int result) {
        this._result = result;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
    }
}

