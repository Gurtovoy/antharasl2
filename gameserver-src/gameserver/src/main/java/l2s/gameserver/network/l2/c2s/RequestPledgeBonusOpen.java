/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPledgeBonusOpen;
import l2s.gameserver.network.l2.s2c.ExPledgeClassicRaidInfo;

public class RequestPledgeBonusOpen
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
        if (activeChar.getClan() == null) {
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExPledgeBonusOpen(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new ExPledgeClassicRaidInfo(activeChar));
    }
}

