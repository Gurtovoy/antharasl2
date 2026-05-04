/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestSetAllyCrest
extends L2GameClientPacket {
    private int _length;
    private byte[] _data;

    @Override
    protected boolean readImpl() {
        this._length = this.readD();
        if (this._length == 192 && this._length == this._buf.remaining()) {
            this._data = new byte[this._length];
            this.readB(this._data);
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Alliance ally = activeChar.getAlliance();
        if (ally != null && activeChar.isAllyLeader()) {
            int crestId = 0;
            if (this._data != null) {
                crestId = CrestCache.getInstance().saveAllyCrest(ally.getAllyId(), this._data);
            } else if (ally.hasAllyCrest()) {
                CrestCache.getInstance().removeAllyCrest(ally.getAllyId());
            }
            ally.setAllyCrestId(crestId);
            ally.broadcastAllyStatus();
        }
    }
}

