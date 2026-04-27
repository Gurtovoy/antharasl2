/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExMPCCShowPartyMemberInfo;

public class RequestExMPCCShowPartyMembersInfo
extends L2GameClientPacket {
    private int _objectId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || !activeChar.isInParty() || !activeChar.getParty().isInCommandChannel()) {
            return;
        }
        for (Party party : activeChar.getParty().getCommandChannel().getParties()) {
            Player leader = party.getPartyLeader();
            if (leader == null || leader.getObjectId() != this._objectId) continue;
            activeChar.sendPacket((IBroadcastPacket)new ExMPCCShowPartyMemberInfo(party));
            break;
        }
    }
}

