/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestAcceptWaitingSubstitute
extends L2GameClientPacket {
    private int _flag;
    private int _unk1;
    private int _unk2;

    @Override
    protected boolean readImpl() {
        this._flag = this.readD();
        this._unk1 = this.readD();
        this._unk2 = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

