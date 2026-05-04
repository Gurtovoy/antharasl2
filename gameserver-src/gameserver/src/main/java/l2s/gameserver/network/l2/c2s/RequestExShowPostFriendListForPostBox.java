package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExReceiveShowPostFriend;

public class RequestExShowPostFriendListForPostBox
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() throws Exception {
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        player.sendPacket((IBroadcastPacket)new ExReceiveShowPostFriend(player));
    }
}

