/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.PledgeCrestPacket;

public class RequestPledgeCrest
extends L2GameClientPacket {
    private int _crestId;

    @Override
    protected boolean readImpl() {
        this._crestId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._crestId == 0) {
            return;
        }
        byte[] data = CrestCache.getInstance().getPledgeCrest(this._crestId);
        if (data != null) {
            PledgeCrestPacket pc = new PledgeCrestPacket(this._crestId, data);
            this.sendPacket((L2GameServerPacket)pc);
        }
    }
}

