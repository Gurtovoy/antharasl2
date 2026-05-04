/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.AllianceCrestPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestAllyCrest
extends L2GameClientPacket {
    private int _crestId;

    @Override
    protected boolean readImpl() {
        this._crestId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        if (this._crestId == 0) {
            return;
        }
        byte[] data = CrestCache.getInstance().getAllyCrest(this._crestId);
        if (data != null) {
            AllianceCrestPacket ac = new AllianceCrestPacket(this._crestId, data);
            this.sendPacket((L2GameServerPacket)ac);
        }
    }
}

