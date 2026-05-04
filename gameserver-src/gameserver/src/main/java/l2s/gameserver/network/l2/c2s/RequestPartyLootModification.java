package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestPartyLootModification
extends L2GameClientPacket {
    private byte _mode;

    @Override
    protected boolean readImpl() {
        this._mode = (byte)this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._mode < 0 || this._mode > 4) {
            return;
        }
        Party party = activeChar.getParty();
        if (party == null || this._mode == party.getLootDistribution() || party.getPartyLeader() != activeChar) {
            return;
        }
        party.requestLootChange(this._mode);
    }
}

