package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestOustPartyMember
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() {
        this._name = this.readS(16);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Party party = activeChar.getParty();
        if (party == null || !activeChar.getParty().isLeader(activeChar)) {
            activeChar.sendActionFailed();
            return;
        }
        Player member = party.getPlayerByName(this._name);
        if (member == activeChar) {
            activeChar.sendActionFailed();
            return;
        }
        if (member == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInOlympiadMode() || member.isInOlympiadMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_EXPEL_THE_PARTY_MEMBER);
            return;
        }
        for (Event event : member.getEvents()) {
            if (event.canLeaveParty(member)) continue;
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_WITHDRAW_FROM_THE_PARTY);
            return;
        }
        Reflection r = party.getReflection();
        if (r != null) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestOustPartyMember.CantOustInDungeon"));
        } else {
            party.removePartyMember(member, true, false);
        }
    }
}

