package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestExJoinMpccRoom
extends L2GameClientPacket {
    private int _roomId;

    @Override
    protected boolean readImpl() throws Exception {
        this._roomId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (player.getMatchingRoom() != null) {
            return;
        }
        MatchingRoom room = MatchingRoomManager.getInstance().getMatchingRoom(MatchingRoom.CC_MATCHING, this._roomId);
        if (room == null) {
            return;
        }
        room.addMember(player);
    }
}

