package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;

public class ExPCCafeRequestOpenWindowWithoutNPC
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        HtmlMessage html = new HtmlMessage(5);
        html.setFile("pc_bang_shop.htm");
        activeChar.sendPacket((IBroadcastPacket)html);
    }
}

