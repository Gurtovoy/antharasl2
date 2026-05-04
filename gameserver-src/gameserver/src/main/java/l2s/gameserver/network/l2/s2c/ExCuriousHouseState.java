/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExCuriousHouseState
extends L2GameServerPacket {
    public static final L2GameServerPacket IDLE = new ExCuriousHouseState(0);
    public static final L2GameServerPacket INVITE = new ExCuriousHouseState(1);
    public static final L2GameServerPacket PREPARE = new ExCuriousHouseState(2);
    private int _state;

    public ExCuriousHouseState(int state) {
        this._state = state;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._state);
    }
}

