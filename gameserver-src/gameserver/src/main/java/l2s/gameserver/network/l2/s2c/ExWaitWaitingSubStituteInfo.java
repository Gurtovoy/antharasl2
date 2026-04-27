/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExWaitWaitingSubStituteInfo
extends L2GameServerPacket {
    public static final L2GameServerPacket OPEN = new ExWaitWaitingSubStituteInfo(true);
    public static final L2GameServerPacket CLOSE = new ExWaitWaitingSubStituteInfo(false);
    private boolean _open;

    public ExWaitWaitingSubStituteInfo(boolean open) {
        this._open = open;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._open);
    }
}

