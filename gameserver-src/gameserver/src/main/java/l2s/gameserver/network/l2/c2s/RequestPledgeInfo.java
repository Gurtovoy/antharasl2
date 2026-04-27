/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.PledgeInfoPacket;
import l2s.gameserver.tables.ClanTable;

public class RequestPledgeInfo
extends L2GameClientPacket {
    private int _clanId;

    @Override
    protected boolean readImpl() {
        this._clanId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._clanId < 10000000) {
            activeChar.sendActionFailed();
            return;
        }
        Clan clan = ClanTable.getInstance().getClan(this._clanId);
        if (clan == null) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new PledgeInfoPacket(clan));
    }
}

