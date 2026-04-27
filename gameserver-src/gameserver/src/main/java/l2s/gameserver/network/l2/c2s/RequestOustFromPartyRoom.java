/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestOustFromPartyRoom
extends L2GameClientPacket {
    private int _objectId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        MatchingRoom room = player.getMatchingRoom();
        if (room == null || room.getType() != MatchingRoom.PARTY_MATCHING) {
            return;
        }
        if (room.getLeader() != player) {
            return;
        }
        Player member = GameObjectsStorage.getPlayer(this._objectId);
        if (member == null) {
            return;
        }
        int type = room.getMemberType(member);
        if (type == MatchingRoom.ROOM_MASTER) {
            return;
        }
        if (type == MatchingRoom.PARTY_MEMBER) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DISMISS_A_PARTY_MEMBER_BY_FORCE);
            return;
        }
        room.removeMember(member, true);
    }
}

