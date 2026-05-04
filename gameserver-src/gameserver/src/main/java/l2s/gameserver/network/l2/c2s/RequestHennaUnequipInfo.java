/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.HennaHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.HennaUnequipInfoPacket;
import l2s.gameserver.templates.HennaTemplate;

public class RequestHennaUnequipInfo
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
        HennaTemplate henna = HennaHolder.getInstance().getHenna(this._symbolId);
        if (henna != null) {
            player.sendPacket((IBroadcastPacket)new HennaUnequipInfoPacket(henna, player));
        }
    }
}

