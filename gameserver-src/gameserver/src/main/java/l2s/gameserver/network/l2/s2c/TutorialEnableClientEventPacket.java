/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class TutorialEnableClientEventPacket
extends L2GameServerPacket {
    private int _event = 0;

    public TutorialEnableClientEventPacket(int event) {
        this._event = event;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._event);
    }
}

