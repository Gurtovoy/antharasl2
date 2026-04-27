/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.admincommands.impl;

import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;

public class AdminHelpPage
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().Menu) {
            return false;
        }
        switch (command) {
            case admin_showhtml: {
                if (wordList.length != 2) {
                    activeChar.sendMessage("Usage: //showhtml <file>");
                    return false;
                }
                activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/" + wordList[1]));
            }
        }
        return true;
    }

    public static void showHelpHtml(Player targetChar, String content) {
        HtmlMessage adminReply = new HtmlMessage(5);
        if (content.contains(".htm")) {
            adminReply.setFile("admin/" + content);
        } else {
            adminReply.setHtml(content);
        }
        targetChar.sendPacket((IBroadcastPacket)adminReply);
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_showhtml;

    }
}

