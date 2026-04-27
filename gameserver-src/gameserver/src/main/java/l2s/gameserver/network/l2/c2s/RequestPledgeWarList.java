/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.PledgeReceiveWarList;

public class RequestPledgeWarList
extends L2GameClientPacket {
    static int _type;
    private int _page;

    @Override
    protected boolean readImpl() {
        this._page = this.readD();
        _type = this.readD();
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
        activeChar.sendPacket((IBroadcastPacket)new PledgeReceiveWarList(clan, _type, this._page));
    }
}

