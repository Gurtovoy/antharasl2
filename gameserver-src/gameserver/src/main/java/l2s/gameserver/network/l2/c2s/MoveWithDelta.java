/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class MoveWithDelta
extends L2GameClientPacket {
    private int _dx;
    private int _dy;
    private int _dz;

    @Override
    protected boolean readImpl() {
        this._dx = this.readD();
        this._dy = this.readD();
        this._dz = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

