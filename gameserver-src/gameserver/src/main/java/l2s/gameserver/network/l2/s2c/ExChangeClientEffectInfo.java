/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExChangeClientEffectInfo
extends L2GameServerPacket {
    private int _unk1;
    private int _unk2;
    private int _state;

    public ExChangeClientEffectInfo(int state) {
        this._unk1 = 0;
        this._unk2 = 0;
        this._state = state;
    }

    public ExChangeClientEffectInfo(int unk1, int unk2, int state) {
        this._unk1 = unk1;
        this._unk2 = unk2;
        this._state = state;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._unk1);
        this.writeD(this._unk2);
        this.writeD(this._state);
    }
}

