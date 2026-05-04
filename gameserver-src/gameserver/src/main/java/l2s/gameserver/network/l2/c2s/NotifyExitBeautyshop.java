package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class NotifyExitBeautyshop
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() throws Exception {
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.unblock();
        activeChar.broadcastCharInfo();
    }
}

