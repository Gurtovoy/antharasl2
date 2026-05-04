/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PledgeReceiveMemberInfo;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestPledgeSetAcademyMaster
extends L2GameClientPacket {
    private int _mode;
    private String _sponsorName;
    private String _apprenticeName;

    @Override
    protected boolean readImpl() {
        this._mode = this.readD();
        this._sponsorName = this.readS(16);
        this._apprenticeName = this.readS(16);
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
            return;
        }
        if ((activeChar.getClanPrivileges() & 0x100) == 256) {
            UnitMember sponsor = activeChar.getClan().getAnyMember(this._sponsorName);
            UnitMember apprentice = activeChar.getClan().getAnyMember(this._apprenticeName);
            if (sponsor != null && apprentice != null) {
                if (apprentice.getPledgeType() != -1 || sponsor.getPledgeType() == -1) {
                    return;
                }
                if (this._mode == 1) {
                    if (sponsor.hasApprentice()) {
                        activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestOustAlly.MemberAlreadyHasApprentice"));
                        return;
                    }
                    if (apprentice.hasSponsor()) {
                        activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestOustAlly.ApprenticeAlreadyHasSponsor"));
                        return;
                    }
                    sponsor.setApprentice(apprentice.getObjectId());
                    clan.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(apprentice));
                    clan.broadcastToOnlineMembers(new IBroadcastPacket[]{((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_HAS_BEEN_DESIGNATED_AS_THE_APPRENTICE_OF_CLAN_MEMBER_S1).addString(sponsor.getName())).addString(apprentice.getName())});
                } else {
                    if (!sponsor.hasApprentice()) {
                        activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestOustAlly.MemberHasNoApprentice"));
                        return;
                    }
                    sponsor.setApprentice(0);
                    clan.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(apprentice));
                    clan.broadcastToOnlineMembers(new IBroadcastPacket[]{((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_CLAN_MEMBER_C1S_APPRENTICE_HAS_BEEN_REMOVED).addString(sponsor.getName())).addString(apprentice.getName())});
                }
                if (apprentice.isOnline()) {
                    apprentice.getPlayer().broadcastCharInfo();
                }
                activeChar.sendPacket((IBroadcastPacket)new PledgeReceiveMemberInfo(sponsor));
            }
        } else {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestOustAlly.NoMasterRights"));
        }
    }
}

