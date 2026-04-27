/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.admincommands.impl;

import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class AdminDoorControl
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().Door) {
            return false;
        }
        switch (command) {
            case admin_open: {
                GameObject target = wordList.length > 1 ? World.getAroundObjectById(activeChar, Integer.parseInt(wordList[1])) : activeChar.getTarget();
                if (target != null && target.isDoor()) {
                    ((DoorInstance)target).openMe();
                    break;
                }
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
                break;
            }
            case admin_close: {
                GameObject target = wordList.length > 1 ? World.getAroundObjectById(activeChar, Integer.parseInt(wordList[1])) : activeChar.getTarget();
                if (target != null && target.isDoor()) {
                    ((DoorInstance)target).closeMe();
                    break;
                }
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            }
        }
        return true;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_open,
        admin_close;

    }
}

