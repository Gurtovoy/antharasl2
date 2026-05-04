/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class AnswerJoinPartyRoom
extends L2GameClientPacket {
    private int _response;

    @Override
    protected boolean readImpl() {
        this._response = this._buf.hasRemaining() ? this.readD() : 0;
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Request request = activeChar.getRequest();
        if (request == null || !request.isTypeOf(Request.L2RequestType.PARTY_ROOM)) {
            return;
        }
        if (!request.isInProgress()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isOutOfControl()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        Player requestor = request.getRequestor();
        if (requestor == null) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
            activeChar.sendActionFailed();
            return;
        }
        if (requestor.getRequest() != request) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (this._response == 0) {
            request.cancel(new IBroadcastPacket[0]);
            requestor.sendPacket((IBroadcastPacket)SystemMsg.THE_PLAYER_DECLINED_TO_JOIN_YOUR_PARTY);
            return;
        }
        if (activeChar.getMatchingRoom() != null) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        try {
            MatchingRoom room = requestor.getMatchingRoom();
            if (room == null || room.getType() != MatchingRoom.PARTY_MATCHING) {
                return;
            }
            room.addMember(activeChar);
        }
        finally {
            request.done(new IBroadcastPacket[0]);
        }
    }
}

