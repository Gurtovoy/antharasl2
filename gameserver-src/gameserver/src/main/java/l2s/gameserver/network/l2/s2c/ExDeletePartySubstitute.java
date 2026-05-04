/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExDeletePartySubstitute
extends L2GameServerPacket {
    private final int _obj;

    public ExDeletePartySubstitute(int objectId) {
        this._obj = objectId;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._obj);
    }
}

