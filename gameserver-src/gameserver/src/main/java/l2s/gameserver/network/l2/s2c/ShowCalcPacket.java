/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ShowCalcPacket
extends L2GameServerPacket {
    private int _calculatorId;

    public ShowCalcPacket(int calculatorId) {
        this._calculatorId = calculatorId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._calculatorId);
    }
}

