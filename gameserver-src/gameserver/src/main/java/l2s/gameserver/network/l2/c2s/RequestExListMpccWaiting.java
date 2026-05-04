package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExListMpccWaiting;

public class RequestExListMpccWaiting
extends L2GameClientPacket {
    private int _listId;
    private int _locationId;
    private boolean _allLevels;

    @Override
    protected boolean readImpl() throws Exception {
        this._listId = this.readD();
        this._locationId = this.readD();
        this._allLevels = this.readD() == 1;
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        player.sendPacket((IBroadcastPacket)new ExListMpccWaiting(player, this._listId, this._locationId, this._allLevels));
    }
}

