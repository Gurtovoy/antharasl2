/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class TradeDonePacket
extends L2GameServerPacket {
    public static final L2GameServerPacket SUCCESS = new TradeDonePacket(1);
    public static final L2GameServerPacket FAIL = new TradeDonePacket(0);
    private int _response;

    private TradeDonePacket(int num) {
        this._response = num;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._response);
    }
}

