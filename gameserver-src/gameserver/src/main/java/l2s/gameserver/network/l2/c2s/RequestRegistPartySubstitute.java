/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExRegistPartySubstitute;

public class RequestRegistPartySubstitute
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
        if (activeChar == null) {
            return;
        }
        Party party = activeChar.getParty();
        if (party == null || party.getPartyLeader() != activeChar) {
            return;
        }
        Player target = World.getPlayer(this._objectId);
        if (target != null && target.getParty() == party && !target.isPartySubstituteStarted()) {
            target.startSubstituteTask();
            activeChar.sendPacket(new ExRegistPartySubstitute(this._objectId), SystemMsg.LOOKING_FOR_A_PLAYER_WHO_WILL_REPLACE_THE_SELECTED_PARTY_MEMBER);
        }
    }
}

