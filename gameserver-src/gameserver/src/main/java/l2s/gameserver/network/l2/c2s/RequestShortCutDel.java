/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestShortCutDel
extends L2GameClientPacket {
    private int _slot;
    private int _page;

    @Override
    protected boolean readImpl() {
        int id = this.readD();
        this._slot = id % 12;
        this._page = id / 12;
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.deleteShortCut(this._slot, this._page);
    }
}

