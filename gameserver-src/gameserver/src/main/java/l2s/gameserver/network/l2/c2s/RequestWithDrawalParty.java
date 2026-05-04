package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestWithDrawalParty
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Party party = activeChar.getParty();
        if (party == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInOlympiadMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_WITHDRAW_FROM_THE_PARTY);
            return;
        }
        for (Event event : activeChar.getEvents()) {
            if (event.canLeaveParty(activeChar)) continue;
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_WITHDRAW_FROM_THE_PARTY);
            return;
        }
        Reflection r = activeChar.getParty().getReflection();
        if (r != null && activeChar.isInCombat()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_WITHDRAW_FROM_THE_PARTY);
        } else {
            activeChar.leaveParty(false);
        }
    }
}

