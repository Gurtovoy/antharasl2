/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class RequestReplySurrenderPledgeWar
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestReplySurrenderPledgeWar.class);
    private String _reqName;
    private int _answer;

    @Override
    protected boolean readImpl() {
        this._reqName = this.readS();
        this._answer = this.readD();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Enabled force condition propagation
     * Lifted jumps to return sites
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Request request = activeChar.getRequest();
        if (request == null || !request.isTypeOf(Request.L2RequestType.CLAN_WAR_SURRENDER)) {
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
                if (war == null) return;
                war.setPeriod(ClanWar.ClanWarPeriod.PEACE);
                return;
            }
            finally {
                request.done(new IBroadcastPacket[0]);
            }
        } else {
            _log.warn(this.getClass().getSimpleName() + ": Missing implementation for answer: " + this._answer + " and name: " + this._reqName + "!");
            request.cancel(new IBroadcastPacket[0]);
        }
    }
}

