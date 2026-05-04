package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.ObservableArena;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.utils.NpcUtils;

public class RequestOlympiadMatchList
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (NpcUtils.canPassPacket(player, this, new Object[0]) != null) {
            return;
        }
        ObservableArena arena = player.getObservableArena();
        if (arena == null) {
            return;
        }
        arena.showObservableArenasList(player);
    }
}

