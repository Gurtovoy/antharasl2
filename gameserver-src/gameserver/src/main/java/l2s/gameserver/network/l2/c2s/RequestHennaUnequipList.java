/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.HennaUnequipListPacket;

public class RequestHennaUnequipList
extends L2GameClientPacket {
    private int _symbolId;

    @Override
    protected boolean readImpl() {
        this._symbolId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        HennaUnequipListPacket he = new HennaUnequipListPacket(activeChar);
        activeChar.sendPacket((IBroadcastPacket)he);
    }
}

