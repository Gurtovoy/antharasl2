/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.clansearch.ClanSearchPlayer;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPledgeWaitingList;
import l2s.gameserver.network.l2.s2c.ExPledgeWaitingUser;

public class RequestPledgeWaitingUser
extends L2GameClientPacket {
    private int _clanId;
    private int _charId;

    @Override
    protected boolean readImpl() {
        this._clanId = this.readD();
        this._charId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        ClanSearchPlayer csPlayer = ClanSearchManager.getInstance().getApplicant(this._clanId, this._charId);
        if (csPlayer == null) {
            activeChar.sendPacket((IBroadcastPacket)new ExPledgeWaitingList(this._clanId));
        } else {
            activeChar.sendPacket((IBroadcastPacket)new ExPledgeWaitingUser(this._charId, csPlayer.getDesc()));
        }
    }
}

