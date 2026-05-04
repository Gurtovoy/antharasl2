/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestWithdrawPartyRoom
extends L2GameClientPacket {
    private int _roomId;

    @Override
    protected boolean readImpl() {
        this._roomId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        MatchingRoom room = player.getMatchingRoom();
        if (room == null || room.getId() != this._roomId || room.getType() != MatchingRoom.PARTY_MATCHING) {
            return;
        }
        int type = room.getMemberType(player);
        if (type == MatchingRoom.ROOM_MASTER || type == MatchingRoom.PARTY_MEMBER) {
            player.setMatchingRoomWindowOpened(false);
            return;
        }
        room.removeMember(player, false);
    }
}

