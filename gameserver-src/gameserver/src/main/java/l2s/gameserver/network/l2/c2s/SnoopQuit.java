package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class SnoopQuit
extends L2GameClientPacket {
    private int _snoopID;

    @Override
    protected boolean readImpl() {
        this._snoopID = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Player player = (Player)GameObjectsStorage.findObject(this._snoopID);
        if (player == null) {
            return;
        }
        player.removeSnooper(activeChar);
    }
}

