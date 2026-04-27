/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;

public class RequestPledgeSetMemberPowerGrade
extends L2GameClientPacket {
    private int _powerGrade;
    private String _name;

    @Override
    protected boolean readImpl() {
        this._name = this.readS(16);
        this._powerGrade = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._powerGrade < 1 || this._powerGrade > 9) {
            return;
        }
        Clan clan = activeChar.getClan();
        if (clan == null) {
            return;
        }
        if ((activeChar.getClanPrivileges() & 0x10) == 16) {
            UnitMember member = activeChar.getClan().getAnyMember(this._name);
            if (member != null) {
                if (Clan.isAcademy(member.getPledgeType())) {
                    activeChar.sendMessage("You cannot change academy member grade.");
                    return;
                }
                if (this._powerGrade > 5) {
                    member.setPowerGrade(clan.getAffiliationRank(member.getPledgeType()));
                } else {
                    member.setPowerGrade(this._powerGrade);
                }
                if (member.isOnline()) {
                    member.getPlayer().sendUserInfo();
                }
            } else {
                activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeSetMemberPowerGrade.NotBelongClan"));
            }
        } else {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestPledgeSetMemberPowerGrade.HaveNotAuthority"));
        }
    }
}

