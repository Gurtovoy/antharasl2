/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.JoinPartyPacket;

public class RequestAnswerJoinParty
extends L2GameClientPacket {
    private int _response;

    @Override
    protected boolean readImpl() {
        this._response = this._buf.hasRemaining() ? this.readD() : 0;
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
        if (request == null || !request.isTypeOf(Request.L2RequestType.PARTY)) {
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
        if (this._response <= 0) {
            request.cancel(new IBroadcastPacket[0]);
            requestor.sendPacket((IBroadcastPacket)JoinPartyPacket.FAIL);
            return;
        }
        if (activeChar.isInOlympiadMode()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_PARTY_CANNOT_BE_FORMED_IN_THIS_AREA);
            requestor.sendPacket((IBroadcastPacket)JoinPartyPacket.FAIL);
            return;
        }
        if (requestor.isInOlympiadMode()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_INVITE_A_FRIEND_OR_PARTY_WHILE_PARTICIPATING_IN_THE_CEREMONY_OF_CHAOS);
            requestor.sendPacket((IBroadcastPacket)JoinPartyPacket.FAIL);
            return;
        }
        Party party = requestor.getParty();
        if (party != null && party.getMemberCount() >= Party.MAX_SIZE) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_PARTY_IS_FULL);
            requestor.sendPacket((IBroadcastPacket)SystemMsg.THE_PARTY_IS_FULL);
            requestor.sendPacket((IBroadcastPacket)JoinPartyPacket.FAIL);
            return;
        }
        IBroadcastPacket problem = activeChar.canJoinParty(requestor);
        if (problem != null) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket(problem, ActionFailPacket.STATIC);
            requestor.sendPacket((IBroadcastPacket)JoinPartyPacket.FAIL);
            return;
        }
        if (party == null) {
            int itemDistribution = request.getInteger("itemDistribution");
            party = new Party(requestor, itemDistribution);
            requestor.setParty(party);
        }
        try {
            activeChar.joinParty(party, false);
            requestor.sendPacket((IBroadcastPacket)JoinPartyPacket.SUCCESS);
        }
        finally {
            request.done(new IBroadcastPacket[0]);
        }
    }
}

