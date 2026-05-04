package l2s.gameserver.network.l2.c2s;

import java.util.HashSet;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExMpccPartymasterList;

public class RequestExMpccPartymasterList
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
        MatchingRoom room = player.getMatchingRoom();
        if (room == null || room.getType() != MatchingRoom.CC_MATCHING) {
            return;
        }
        HashSet<String> set = new HashSet<String>();
        for (Player $member : room.getPlayers()) {
            if ($member.getParty() == null) continue;
            set.add($member.getParty().getPartyLeader().getName());
        }
        player.sendPacket((IBroadcastPacket)new ExMpccPartymasterList(set));
    }
}

