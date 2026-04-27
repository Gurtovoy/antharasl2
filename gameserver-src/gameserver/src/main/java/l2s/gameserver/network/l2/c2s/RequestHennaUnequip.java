/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Henna;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestHennaUnequip
extends L2GameClientPacket {
    private int _symbolId;

    @Override
    protected boolean readImpl() {
        this._symbolId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Henna henna = player.getHennaList().get(this._symbolId);
        if (henna == null) {
            return;
        }
        long removePrice = henna.getTemplate().getRemovePrice();
        if (removePrice > 0L && !player.reduceAdena(removePrice)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
            return;
        }
        if (player.getHennaList().remove(henna)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_SYMBOL_HAS_BEEN_DELETED);
        }
    }
}

