/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.usercommands.impl;

import java.text.SimpleDateFormat;
import l2s.gameserver.Config;
import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.handler.usercommands.IUserCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.utils.HtmlUtils;

public class ClanPenalty
implements IUserCommandHandler {
    private static final int[] COMMAND_IDS = new int[]{100, 114};
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd-MM-yyyy");

    @Override
    public boolean useUserCommand(int id, Player activeChar) {
        if (COMMAND_IDS[0] != id) {
            return false;
        }
        long leaveClan = 0L;
        if (activeChar.getLeaveClanTime() != 0L) {
            leaveClan = activeChar.getLeaveClanTime() + (long)(Config.ALT_CLAN_LEAVE_PENALTY_TIME * 60 * 60) * 1000L;
        }
        long deleteClan = 0L;
        if (activeChar.getDeleteClanTime() != 0L) {
            deleteClan = activeChar.getDeleteClanTime() + (long)(Config.ALT_CLAN_CREATE_PENALTY_TIME * 60 * 60) * 1000L;
        }
        String html = HtmCache.getInstance().getHtml("command/penalty.htm", activeChar);
        if (activeChar.getClanId() == 0) {
            if (leaveClan == 0L && deleteClan == 0L) {
                html = html.replace("%reason%", new CustomMessage("l2s.gameserver.handler.usercommands.impl.ClanPenalty.PenaltyImposed").toString(activeChar));
                html = html.replace("%expiration%", " ");
            } else if (leaveClan > 0L && deleteClan == 0L) {
                html = html.replace("%reason%", new CustomMessage("l2s.gameserver.handler.usercommands.impl.ClanPenalty.PenaltyLeaving").toString(activeChar));
                html = html.replace("%expiration%", DATE_FORMAT.format(leaveClan));
            } else if (deleteClan > 0L) {
                html = html.replace("%reason%", new CustomMessage("l2s.gameserver.handler.usercommands.impl.ClanPenalty.PenaltyDissolving").toString(activeChar));
                html = html.replace("%expiration%", DATE_FORMAT.format(deleteClan));
            }
        } else if (activeChar.getClan().canInvite()) {
            html = html.replace("%reason%", new CustomMessage("l2s.gameserver.handler.usercommands.impl.ClanPenalty.PenaltyImposed").toString(activeChar));
            html = html.replace("%expiration%", " ");
        } else {
            html = html.replace("%reason%", new CustomMessage("l2s.gameserver.handler.usercommands.impl.ClanPenalty.PenaltyExpelling").toString(activeChar));
            html = html.replace("%expiration%", DATE_FORMAT.format(activeChar.getClan().getExpelledMemberTime()));
        }
        HtmlMessage msg = new HtmlMessage(5);
        msg.setHtml(HtmlUtils.bbParse(html));
        activeChar.sendPacket((IBroadcastPacket)msg);
        return true;
    }

    @Override
    public final int[] getUserCommandList() {
        return COMMAND_IDS;
    }
}

