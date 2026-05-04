/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestUpdateFriendMemo
extends L2GameClientPacket {
    private String _name;
    private String _memo;

    @Override
    protected boolean readImpl() {
        this._name = this.readS();
        this._memo = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.getFriendList().updateMemo(this._name, this._memo);
    }
}

