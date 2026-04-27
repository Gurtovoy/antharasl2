/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.admincommands.impl;

import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;

public class AdminTarget
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().CanViewChar) {
            return false;
        }
        try {
            String targetName = wordList[1];
            Player obj = World.getPlayer(targetName);
            if (obj != null && ((GameObject)obj).isPlayer()) {
                ((GameObject)obj).onAction(activeChar, false);
            } else {
                activeChar.sendMessage("Player " + targetName + " not found");
            }
        }
        catch (IndexOutOfBoundsException e) {
            activeChar.sendMessage("Please specify correct name.");
        }
        return true;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_target;

    }
}

