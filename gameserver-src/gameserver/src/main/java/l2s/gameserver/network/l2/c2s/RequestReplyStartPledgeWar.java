/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class RequestReplyStartPledgeWar
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestReplyStartPledgeWar.class);
    private int _answer;

    @Override
    protected boolean readImpl() {
        this.readS();
        this._answer = this.readD();
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Request request = activeChar.getRequest();
        if (request == null || !request.isTypeOf(Request.L2RequestType.CLAN_WAR_START)) {
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
            activeChar.sendActionFailed();
            return;
        }
        if (requestor.getRequest() != request) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        Clan clan = requestor.getClan();
        if (clan == null) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (this._answer == 1) {
            try {
                ClanWar war = clan.getWarWith(activeChar.getClanId());
                if (war == null) {
                    _log.warn(this.getClass().getSimpleName() + ": Opponent clan war object not found!");
                    request.cancel(new IBroadcastPacket[0]);
                    activeChar.sendActionFailed();
                    return;
                }
                if (war.getPeriod() != ClanWar.ClanWarPeriod.PREPARATION) {
                    request.cancel(new IBroadcastPacket[0]);
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_ALREADY_BEEN_AT_WAR_WITH_THE_S1_CLAN_5_DAYS_MUST_PASS_BEFORE_YOU_CAN_DECLARE_WAR_AGAIN).addString(requestor.getClan().getName()));
                    return;
                }
                war.setPeriod(ClanWar.ClanWarPeriod.MUTUAL);
            }
            finally {
                request.done(new IBroadcastPacket[0]);
            }
        } else {
            requestor.sendPacket((IBroadcastPacket)SystemMsg.THE_S1_CLAN_DID_NOT_RESPOND_WAR_PROCLAMATION_HAS_BEEN_REFUSED);
            request.cancel(new IBroadcastPacket[0]);
        }
    }
}

