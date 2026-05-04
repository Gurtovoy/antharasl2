/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestPledgeReorganizeMember
extends L2GameClientPacket {
    int _replace;
    String _subjectName;
    int _targetUnit;
    String _replaceName;

    @Override
    protected boolean readImpl() {
        this._replace = this.readD();
        this._subjectName = this.readS(16);
        this._targetUnit = this.readD();
        if (this._replace > 0) {
            this._replaceName = this.readS();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Clan clan = activeChar.getClan();
        if (clan == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (!activeChar.isClanLeader()) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.ChangeAffiliations"));
            activeChar.sendActionFailed();
            return;
        }
        UnitMember subject = clan.getAnyMember(this._subjectName);
        if (subject == null) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.NotInYourClan"));
            activeChar.sendActionFailed();
            return;
        }
        if (subject.getPledgeType() == this._targetUnit) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.AlreadyInThatCombatUnit"));
            activeChar.sendActionFailed();
            return;
        }
        if (this._targetUnit != 0 && clan.getSubUnit(this._targetUnit) == null) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.NoSuchCombatUnit"));
            activeChar.sendActionFailed();
            return;
        }
        if (Clan.isAcademy(this._targetUnit)) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.AcademyViaInvitation"));
            activeChar.sendActionFailed();
            return;
        }
        if (Clan.isAcademy(subject.getPledgeType())) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.CantMoveAcademyMember"));
            activeChar.sendActionFailed();
            return;
        }
        UnitMember replacement = null;
        if (this._replace > 0) {
            replacement = clan.getAnyMember(this._replaceName);
            if (replacement == null) {
                activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.CharacterNotBelongClan"));
                activeChar.sendActionFailed();
                return;
            }
            if (replacement.getPledgeType() != this._targetUnit) {
                activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.CharacterNotBelongCombatUnit"));
                activeChar.sendActionFailed();
                return;
            }
            if (replacement.isSubLeader() != 0) {
                activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.CharacterLeaderAnotherCombatUnit"));
                activeChar.sendActionFailed();
                return;
            }
        } else {
            if (clan.getUnitMembersSize(this._targetUnit) >= clan.getSubPledgeLimit(this._targetUnit)) {
                if (this._targetUnit == 0) {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_IS_FULL_AND_CANNOT_ACCEPT_ADDITIONAL_CLAN_MEMBERS_AT_THIS_TIME).addString(clan.getName()));
                } else {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_ACADEMYROYAL_GUARDORDER_OF_KNIGHTS_IS_FULL_AND_CANNOT_ACCEPT_NEW_MEMBERS_AT_THIS_TIME);
                }
                activeChar.sendActionFailed();
                return;
            }
            if (subject.isSubLeader() != 0) {
                activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember.MemberLeaderAnotherUnit"));
                activeChar.sendActionFailed();
                return;
            }
        }
        SubUnit oldUnit = null;
        if (replacement != null) {
            oldUnit = replacement.getSubUnit();
            oldUnit.replace(replacement.getObjectId(), subject.getPledgeType());
            clan.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(replacement));
            if (replacement.isOnline()) {
                replacement.getPlayer().updatePledgeRank();
                replacement.getPlayer().broadcastCharInfo();
            }
        }
        oldUnit = subject.getSubUnit();
        oldUnit.replace(subject.getObjectId(), this._targetUnit);
        clan.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(subject));
        if (subject.isOnline()) {
            subject.getPlayer().updatePledgeRank();
            subject.getPlayer().broadcastCharInfo();
        }
    }
}

