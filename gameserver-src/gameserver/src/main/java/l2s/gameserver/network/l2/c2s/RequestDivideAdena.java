package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExDivideAdenaDone;

public class RequestDivideAdena
extends L2GameClientPacket {
    private long _count;

    @Override
    protected boolean readImpl() {
        this.readD();
        this._count = this.readQ();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        long count = activeChar.getAdena();
        if (this._count > count) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_PROCEED_AS_THERE_IS_INSUFFICIENT_ADENA);
            return;
        }
        int membersCount = activeChar.getParty().getMemberCount();
        long dividedCount = (long)Math.floor(this._count / (long)membersCount);
        activeChar.reduceAdena((long)membersCount * dividedCount, false);
        for (Player player : activeChar.getParty().getPartyMembers()) {
            player.addAdena(dividedCount, player.getObjectId() != activeChar.getObjectId());
        }
        activeChar.sendPacket((IBroadcastPacket)new ExDivideAdenaDone(membersCount, this._count, dividedCount, activeChar.getName()));
    }
}

