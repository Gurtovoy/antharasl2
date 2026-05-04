/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExOlympiadModePacket
extends L2GameServerPacket {
    private int _mode;

    public ExOlympiadModePacket(int mode) {
        this._mode = mode;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._mode);
    }
}

