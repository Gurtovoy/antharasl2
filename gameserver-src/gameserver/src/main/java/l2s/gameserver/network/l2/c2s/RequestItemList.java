package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestItemList
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (!activeChar.getPlayerAccess().UseInventory || activeChar.isBlocked()) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendItemList(true);
        activeChar.sendStatusUpdate(false, false, 14);
    }
}

