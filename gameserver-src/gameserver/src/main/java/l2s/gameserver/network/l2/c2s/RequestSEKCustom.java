/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestSEKCustom
extends L2GameClientPacket {
    private int SlotNum;
    private int Direction;

    @Override
    protected boolean readImpl() {
        this.SlotNum = this.readD();
        this.Direction = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

