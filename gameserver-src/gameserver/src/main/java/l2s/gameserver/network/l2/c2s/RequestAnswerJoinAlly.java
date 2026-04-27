/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestAnswerJoinAlly
extends L2GameClientPacket {
    private int _response;

    @Override
    protected boolean readImpl() {
        this._response = this._buf.remaining() >= 4 ? this.readD() : 0;
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Request request = activeChar.getRequest();
        if (request == null || !request.isTypeOf(Request.L2RequestType.ALLY)) {
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
        if (requestor.getAlliance() == null) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (this._response == 0) {
            request.cancel(new IBroadcastPacket[0]);
            requestor.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_INVITE_A_CLAN_INTO_THE_ALLIANCE);
            return;
        }
        try {
            Alliance ally = requestor.getAlliance();
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ACCEPTED_THE_ALLIANCE);
            activeChar.getClan().setAllyId(requestor.getAllyId());
            activeChar.getClan().updateClanInDB();
            ally.addAllyMember(activeChar.getClan(), true);
            ally.broadcastAllyStatus();
        }
        finally {
            request.done(new IBroadcastPacket[0]);
        }
    }
}

