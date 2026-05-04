/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestPartyMatchDetail
extends L2GameClientPacket {
    private int _roomId;
    private int _locations;
    private int _level;

    @Override
    protected boolean readImpl() {
        this._roomId = this.readD();
        this._locations = this.readD();
        this._level = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (player.getMatchingRoom() != null) {
            return;
        }
        if (this._roomId > 0) {
            MatchingRoom room = MatchingRoomManager.getInstance().getMatchingRoom(MatchingRoom.PARTY_MATCHING, this._roomId);
            if (room == null) {
                return;
            }
            room.addMember(player);
        } else {
            for (MatchingRoom room : MatchingRoomManager.getInstance().getMatchingRooms(MatchingRoom.PARTY_MATCHING, this._locations, this._level == 1, player)) {
                if (room.addMember(player)) break;
            }
        }
    }
}

