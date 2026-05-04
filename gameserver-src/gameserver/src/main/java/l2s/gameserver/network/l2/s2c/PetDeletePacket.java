/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PetDeletePacket
extends L2GameServerPacket {
    private int _petId;
    private int _petnum;

    public PetDeletePacket(int petId, int petnum) {
        this._petId = petId;
        this._petnum = petnum;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._petnum);
        this.writeD(this._petId);
    }
}

