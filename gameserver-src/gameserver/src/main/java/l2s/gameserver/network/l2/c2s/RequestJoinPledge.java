package l2s.gameserver.network.l2.c2s;

import l2s.commons.util.Rnd;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.c2s.RequestAnswerJoinPledge;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.AskJoinPledgePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestJoinPledge
extends L2GameClientPacket {
    private int _objectId;
    private int _pledgeType;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._pledgeType = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || activeChar.getClan() == null) {
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
        Clan clan = activeChar.getClan();
        if (clan.isPlacedForDisband()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ALREADY_REQUESTED_THE_DISSOLUTION_OF_YOUR_CLAN);
            return;
        }
        if (!clan.canInvite()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.AFTER_A_CLAN_MEMBER_IS_DISMISSED_FROM_A_CLAN_THE_CLAN_MUST_WAIT_AT_LEAST_A_DAY_BEFORE_ACCEPTING_A_NEW_MEMBER);
            return;
        }
        if (this._objectId == activeChar.getObjectId()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_ASK_YOURSELF_TO_APPLY_TO_A_CLAN);
            return;
        }
        if ((activeChar.getClanPrivileges() & 2) != 2) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ONLY_THE_LEADER_CAN_GIVE_OUT_INVITATIONS);
            return;
        }
        if (clan.getUnitMembersSize(this._pledgeType) >= clan.getSubPledgeLimit(this._pledgeType)) {
            if (this._pledgeType == 0) {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_IS_FULL_AND_CANNOT_ACCEPT_ADDITIONAL_CLAN_MEMBERS_AT_THIS_TIME).addString(clan.getName()));
            } else {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_ACADEMYROYAL_GUARDORDER_OF_KNIGHTS_IS_FULL_AND_CANNOT_ACCEPT_NEW_MEMBERS_AT_THIS_TIME);
            }
            return;
        }
        GameObject object = activeChar.getVisibleObject(this._objectId);
        if (object == null || !object.isPlayer()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return;
        }
        Player member = (Player)object;
        if (member.getClan() == activeChar.getClan()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return;
        }
        if (!member.getPlayerAccess().CanJoinClan) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_CANNOT_JOIN_THE_CLAN_BECAUSE_ONE_DAY_HAS_NOT_YET_PASSED_SINCE_THEY_LEFT_ANOTHER_CLAN).addName(member));
            return;
        }
        if (member.getClan() != null) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_IS_ALREADY_A_MEMBER_OF_ANOTHER_CLAN).addName(member));
            return;
        }
        if (member.isBusy()) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ON_ANOTHER_TASK).addName(member));
            return;
        }
        if (member.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REQUEST_TO_A_CHARACTER_WHO_IS_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        if (!clan.checkJoinPledgeCondition(member, this._pledgeType)) {
            if (this._pledgeType == -1) {
                if (member.isAcademyGraduated()) {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_ALREADY_GRADUATED_FROM_A_CLAN_ACADEMY_THEREFORE_REJOINING_IS_NOT_ALLOWED).addName(member));
                } else {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.TO_JOIN_A_CLAN_ACADEMY_CHARACTERS_MUST_BE_LEVEL_40_OR_BELOW_NOT_BELONG_ANOTHER_CLAN_AND_NOT_YET_COMPLETED_THEIR_2ND_CLASS_TRANSFER);
                }
            }
            return;
        }
        Request request = new Request(Request.L2RequestType.CLAN, activeChar, member).setTimeout(10000L);
        request.set("pledgeType", this._pledgeType);
        member.sendPacket((IBroadcastPacket)new AskJoinPledgePacket(activeChar.getObjectId(), activeChar.getClan().getName()));
        if (member.isFakePlayer() && Rnd.chance((int)95)) {
            ThreadPoolManager.getInstance().schedule(() -> RequestAnswerJoinPledge.answerJoinPledge(member, Rnd.chance((int)15)), Rnd.get((int)1000, (int)9500));
        }
    }
}

