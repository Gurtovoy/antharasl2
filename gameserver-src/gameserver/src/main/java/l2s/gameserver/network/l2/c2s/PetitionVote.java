/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class PetitionVote
extends L2GameClientPacket {
    private int _type;
    private int _unk1;
    private String _petitionText;

    @Override
    protected boolean readImpl() {
        this._type = this.readD();
        this._unk1 = this.readD();
        this._petitionText = this.readS(4096);
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

