/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPVPMatchUserDie
extends L2GameServerPacket {
    private int _blueKills;
    private int _redKills;

    public ExPVPMatchUserDie(int blueKills, int redKills) {
        this._blueKills = blueKills;
        this._redKills = redKills;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._blueKills);
        this.writeD(this._redKills);
    }
}

