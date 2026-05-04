package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExListPartyMatchingWaitingRoom;

public class RequestListPartyMatchingWaitingRoom
extends L2GameClientPacket {
    private int _minLevel;
    private int _maxLevel;
    private int _page;
    private int[] _classes;

    @Override
    protected boolean readImpl() {
        this._page = this.readD();
        this._minLevel = this.readD();
        this._maxLevel = this.readD();
        int size = this.readD();
        if (size > 127 || size < 0) {
            size = 0;
        }
        this._classes = new int[size];
        for (int i = 0; i < size; ++i) {
            this._classes[i] = this.readD();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExListPartyMatchingWaitingRoom(activeChar, this._minLevel, this._maxLevel, this._page, this._classes));
    }
}

