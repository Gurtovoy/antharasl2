package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBR_NewIConCashBtnWnd
extends L2GameServerPacket {
    private final int _value;

    public ExBR_NewIConCashBtnWnd(Player player) {
        this._value = player.getProductHistoryList().haveGifts() ? 2 : 0;
    }

    @Override
    protected void writeImpl() {
        this.writeH(this._value);
    }
}

