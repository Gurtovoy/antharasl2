package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestPledgeExtendedInfo
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() {
        this._name = this.readS(16);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isGM()) {
            activeChar.sendMessage("RequestPledgeExtendedInfo");
        }
    }
}

