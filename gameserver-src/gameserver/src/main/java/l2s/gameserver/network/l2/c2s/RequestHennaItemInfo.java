/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.HennaHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.HennaItemInfoPacket;
import l2s.gameserver.templates.HennaTemplate;

public class RequestHennaItemInfo
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
        HennaTemplate template = HennaHolder.getInstance().getHenna(this._symbolId);
        if (template != null) {
            player.sendPacket((IBroadcastPacket)new HennaItemInfoPacket(template, player));
        }
    }
}

