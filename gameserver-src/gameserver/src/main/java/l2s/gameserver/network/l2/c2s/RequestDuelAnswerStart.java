package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.impl.AbstractDuelEvent;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestDuelAnswerStart
extends L2GameClientPacket {
    private int _response;
    private int _duelType;

    @Override
    protected boolean readImpl() {
        this._duelType = this.readD();
        this.readD();
        this._response = this.readD();
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
        if (request == null || !request.isTypeOf(Request.L2RequestType.DUEL)) {
            return;
        }
        if (!request.isInProgress()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isActionsDisabled()) {
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
        if (this._duelType != request.getInteger("duelType")) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        AbstractDuelEvent duelEvent = (AbstractDuelEvent)((Object)EventHolder.getInstance().getEvent(EventType.PVP_EVENT, request.getInteger("eventId", this._duelType)));
        switch (this._response) {
            case 0: {
                request.cancel(new IBroadcastPacket[0]);
                if (this._duelType == 1) {
                    requestor.sendPacket((IBroadcastPacket)SystemMsg.THE_OPPOSING_PARTY_HAS_DECLINED_YOUR_CHALLENGE_TO_A_DUEL);
                    break;
                }
                requestor.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_HAS_DECLINED_YOUR_CHALLENGE_TO_A_PARTY_DUEL).addName(activeChar));
                break;
            }
            case -1: {
                request.cancel(new IBroadcastPacket[0]);
                requestor.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_SET_TO_REFUSE_DUEL_REQUESTS_AND_CANNOT_RECEIVE_A_DUEL_REQUEST).addName(activeChar));
                break;
            }
            case 1: {
                SystemMessagePacket msg2;
                SystemMessagePacket msg1;
                if (!duelEvent.canDuel(requestor, activeChar, false)) {
                    request.cancel(new IBroadcastPacket[0]);
                    return;
                }
                if (this._duelType == 1) {
                    msg1 = new SystemMessagePacket(SystemMsg.YOU_HAVE_ACCEPTED_C1S_CHALLENGE_TO_A_PARTY_DUEL);
                    msg2 = new SystemMessagePacket(SystemMsg.S1_HAS_ACCEPTED_YOUR_CHALLENGE_TO_DUEL_AGAINST_THEIR_PARTY);
                } else {
                    msg1 = new SystemMessagePacket(SystemMsg.YOU_HAVE_ACCEPTED_C1S_CHALLENGE_A_DUEL);
                    msg2 = new SystemMessagePacket(SystemMsg.C1_HAS_ACCEPTED_YOUR_CHALLENGE_TO_A_DUEL);
                }
                activeChar.sendPacket((IBroadcastPacket)msg1.addName(requestor));
                requestor.sendPacket((IBroadcastPacket)msg2.addName(activeChar));
                try {
                    duelEvent.createDuel(requestor, activeChar, request.getInteger("arenaId", 0));
                    break;
                }
                finally {
                    request.done(new IBroadcastPacket[0]);
                }
            }
        }
    }
}

