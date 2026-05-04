package l2s.gameserver.handler.pccoupon;

import l2s.gameserver.model.Player;

public interface IPCCouponHandler {
    public int getType();

    public boolean useCoupon(Player var1, String var2);
}

