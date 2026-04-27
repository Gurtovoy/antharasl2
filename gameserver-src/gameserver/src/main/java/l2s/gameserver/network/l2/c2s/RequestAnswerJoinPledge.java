/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestAnswerJoinPledge
extends L2GameClientPacket {
    private int _response;

    @Override
    protected boolean readImpl() {
        this._response = this._buf.hasRemaining() ? this.readD() : 0;
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        RequestAnswerJoinPledge.answerJoinPledge(player, this._response != 0);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void answerJoinPledge(Player player, boolean confirm) {
        Request request = player.getRequest();
        if (request == null || !request.isTypeOf(Request.L2RequestType.CLAN)) {
            return;
        }
        if (!request.isInProgress()) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendActionFailed();
            return;
        }
        if (player.isOutOfControl()) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendActionFailed();
            return;
        }
        Player requestor = request.getRequestor();
        if (requestor == null) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
            player.sendActionFailed();
            return;
        }
        if (requestor.getRequest() != request) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendActionFailed();
            return;
        }
        Clan clan = requestor.getClan();
        if (clan == null) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendActionFailed();
            return;
        }
        if (!confirm) {
            request.cancel(new IBroadcastPacket[0]);
            requestor.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_DECLINED_YOUR_CLAN_INVITATION).addName(player));
            return;
        }
        if (player.isInTrainingCamp()) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_JOIN_A_CLAN_WHILE_YOU_ARE_IN_THE_TRAINING_CAMP);
            return;
        }
        if (!player.canJoinClan()) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendPacket((IBroadcastPacket)SystemMsg.AFTER_LEAVING_OR_HAVING_BEEN_DISMISSED_FROM_A_CLAN_YOU_MUST_WAIT_AT_LEAST_A_DAY_BEFORE_JOINING_ANOTHER_CLAN);
            return;
        }
        int pledgeType = request.getInteger("pledgeType");
        if (clan.getUnitMembersSize(pledgeType) >= clan.getSubPledgeLimit(pledgeType)) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendActionFailed();
            return;
        }
        if (!clan.checkJoinPledgeCondition(player, pledgeType)) {
            request.cancel(new IBroadcastPacket[0]);
            player.sendActionFailed();
            return;
        }
        try {
            clan.joinInPledge(player, pledgeType);
        }
        finally {
            request.done(new IBroadcastPacket[0]);
        }
    }
}

