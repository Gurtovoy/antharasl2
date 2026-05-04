package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.DuelEvent;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestDuelSurrender
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
        DuelEvent duelEvent = player.getEvent(DuelEvent.class);
        if (duelEvent == null) {
            return;
        }
        duelEvent.packetSurrender(player);
    }
}

