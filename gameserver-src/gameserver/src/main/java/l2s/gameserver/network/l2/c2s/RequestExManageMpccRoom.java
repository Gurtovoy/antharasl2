package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestExManageMpccRoom
extends L2GameClientPacket {
    private int _id;
    private int _memberSize;
    private int _minLevel;
    private int _maxLevel;
    private String _topic;

    @Override
    protected boolean readImpl() {
        this._id = this.readD();
        this._memberSize = this.readD();
        this._minLevel = this.readD();
        this._maxLevel = this.readD();
        this.readD();
        this._topic = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        MatchingRoom room = player.getMatchingRoom();
        if (room == null || room.getId() != this._id || room.getType() != MatchingRoom.CC_MATCHING) {
            return;
        }
        if (room.getLeader() != player) {
            return;
        }
        room.setTopic(this._topic);
        room.setMaxMemberSize(this._memberSize);
        room.setMinLevel(this._minLevel);
        room.setMaxLevel(this._maxLevel);
        room.broadCast(room.infoRoomPacket());
        player.sendPacket((IBroadcastPacket)SystemMsg.THE_COMMAND_CHANNEL_MATCHING_ROOM_INFORMATION_WAS_EDITED);
    }
}

