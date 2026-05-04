/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public final class RequestRegistWaitingSubstitute
extends L2GameClientPacket {
    private boolean _enable;

    @Override
    protected boolean readImpl() {
        this._enable = this.readD() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isAutoSearchParty() != this._enable) {
            if (this._enable) {
                if (activeChar.mayPartySearch(true, true)) {
                    activeChar.enableAutoSearchParty();
                }
            } else {
                activeChar.disablePartySearch(true);
            }
            if (this._enable) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_REGISTERED_ON_THE_WAITING_LIST);
            } else {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.STOPPED_SEARCHING_THE_PARTY);
            }
        }
    }
}

