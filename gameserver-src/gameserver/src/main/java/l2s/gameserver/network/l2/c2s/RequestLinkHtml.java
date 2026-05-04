/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.utils.BypassStorage;
import l2s.gameserver.utils.Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestLinkHtml
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestLinkHtml.class);
    private String _link;

    @Override
    protected boolean readImpl() {
        this._link = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        HtmlMessage msg;
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        BypassStorage.ValidBypass bp = player.getBypassStorage().validate(this._link);
        if (bp == null) {
            _log.warn(" RequestLinkHtml: Unexpected link : " + this._link + "!");
            return;
        }
        String link = bp.bypass;
        int itemId = 0;
        String[] params = link.split(".htm#");
        if (params.length >= 2) {
            link = params[0] + ".htm";
            int n = itemId = !Util.isDigit(params[1]) ? -1 : Integer.parseInt(params[1]);
        }
        if (link.contains("..") || !link.endsWith(".htm") || itemId == -1) {
            _log.warn("RequestLinkHtml: hack? link contains prohibited characters: '" + link + "'!");
            return;
        }
        if (itemId == 0) {
            NpcInstance npc = player.getLastNpc();
            if (npc != null) {
                if (!player.checkInteractionDistance(npc)) {
                    return;
                }
                link = npc.correctBypassLink(player, link);
                msg = new HtmlMessage(npc);
            } else {
                msg = new HtmlMessage(0);
            }
        } else {
            msg = new HtmlMessage(0).setItemId(itemId);
        }
        msg.setFile(link);
        player.sendPacket((IBroadcastPacket)msg);
    }
}

