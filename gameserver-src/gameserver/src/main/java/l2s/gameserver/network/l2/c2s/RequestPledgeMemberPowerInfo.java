package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.PledgeReceivePowerInfo;

public class RequestPledgeMemberPowerInfo
extends L2GameClientPacket {
    private int _not_known;
    private String _target;

    @Override
    protected boolean readImpl() {
        this._not_known = this.readD();
        this._target = this.readS(16);
        return true;
    }

    @Override
    protected void runImpl() {
        UnitMember cm;
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Clan clan = activeChar.getClan();
        if (clan != null && (cm = clan.getAnyMember(this._target)) != null) {
            activeChar.sendPacket((IBroadcastPacket)new PledgeReceivePowerInfo(cm));
        }
    }
}

