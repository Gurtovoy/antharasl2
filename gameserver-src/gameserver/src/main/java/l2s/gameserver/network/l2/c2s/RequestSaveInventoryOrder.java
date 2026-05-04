package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestSaveInventoryOrder
extends L2GameClientPacket {
    int[][] _items;

    @Override
    protected boolean readImpl() {
        int size = this.readD();
        if (size > 125) {
            size = 125;
        }
        if (size * 8 > this._buf.remaining() || size < 1) {
            this._items = null;
            return false;
        }
        this._items = new int[size][2];
        for (int i = 0; i < size; ++i) {
            this._items[i][0] = this.readD();
            this._items[i][1] = this.readD();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        if (this._items == null) {
            return;
        }
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.getInventory().sort(this._items);
    }
}

