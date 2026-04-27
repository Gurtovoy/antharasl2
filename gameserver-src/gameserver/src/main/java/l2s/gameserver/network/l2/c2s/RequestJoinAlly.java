/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.AskJoinAlliancePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestJoinAlly
extends L2GameClientPacket {
    private int _objectId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || activeChar.getAlliance() == null) {
            return;
        }
        Clan clan = activeChar.getClan();
        if (clan == null) {
            return;
        }
        if (activeChar.isOutOfControl()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isProcessingRequest()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WAITING_FOR_ANOTHER_REPLY);
            return;
        }
        if (activeChar.getAlliance().getMembersCount() >= Config.ALT_MAX_ALLY_SIZE) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_INVITE_A_CLAN_INTO_THE_ALLIANCE);
            return;
        }
        if (!activeChar.isAllyLeader()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_FEATURE_IS_ONLY_AVAILABLE_TO_ALLIANCE_LEADERS);
            return;
        }
        if (!activeChar.getAlliance().canInvite()) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestJoinAlly.InvitePenalty"));
            return;
        }
        GameObject obj = activeChar.getVisibleObject(this._objectId);
        if (obj == null || !obj.isPlayer() || obj == activeChar) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return;
        }
        Player target = (Player)obj;
        if (target == null) {
            return;
        }
        Clan targetClan = target.getClan();
        if (targetClan != null && (target.getAlliance() != null || activeChar.getAlliance().isMember(targetClan.getClanId()))) {
            SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.S1_CLAN_IS_ALREADY_A_MEMBER_OF_S2_ALLIANCE);
            sm.addString(targetClan.getName());
            sm.addString(target.getAlliance().getAllyName());
            activeChar.sendPacket((IBroadcastPacket)sm);
            return;
        }
        if (targetClan == null || !target.isClanLeader()) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_IS_NOT_A_CLAN_LEADER).addName(target));
            return;
        }
        if (clan.isAtWarWith(targetClan.getClanId())) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_ALLY_WITH_A_CLAN_YOU_ARE_CURRENTLY_AT_WAR_WITH);
            return;
        }
        if (!targetClan.canJoinAlly()) {
            SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.S1_CLAN_CANNOT_JOIN_THE_ALLIANCE_BECAUSE_ONE_DAY_HAS_NOT_YET_PASSED_SINCE_THEY_LEFT_ANOTHER_ALLIANCE);
            sm.addString(targetClan.getName());
            activeChar.sendPacket((IBroadcastPacket)sm);
            return;
        }
        if (target.isBusy()) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ON_ANOTHER_TASK).addString(target.getName()));
            return;
        }
        if (target.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REQUEST_TO_A_CHARACTER_WHO_IS_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        new Request(Request.L2RequestType.ALLY, activeChar, target).setTimeout(10000L);
        target.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_LEADER_S2_HAS_REQUESTED_AN_ALLIANCE).addString(activeChar.getAlliance().getAllyName())).addName(activeChar));
        target.sendPacket((IBroadcastPacket)new AskJoinAlliancePacket(activeChar.getObjectId(), activeChar.getName(), activeChar.getAlliance().getAllyName()));
    }
}

