/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class SetPrivateStoreMsgBuy
extends L2GameClientPacket {
    private String _storename;

    @Override
    protected boolean readImpl() {
        this._storename = this.readS(32);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.setBuyStoreName(this._storename);
        activeChar.storePrivateStore();
        activeChar.broadcastPrivateStoreInfo();
    }
}

