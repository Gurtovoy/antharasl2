/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExDivideAdenaCancel;

public class RequestDivideAdenaCancel
extends L2GameClientPacket {
    private int _cancel;

    @Override
    protected boolean readImpl() {
        this._cancel = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._cancel == 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ADENA_DISTRIBUTION_HAS_BEEN_CANCELLED);
            activeChar.sendPacket((IBroadcastPacket)ExDivideAdenaCancel.STATIC);
        }
    }
}

