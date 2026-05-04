/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.admincommands.impl;

import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class AdminRes
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().Res) {
            return false;
        }
        if (fullString.startsWith("admin_res ")) {
            this.handleRes(activeChar, wordList[1]);
        }
        if (fullString.equals("admin_res")) {
            this.handleRes(activeChar);
        }
        return true;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private void handleRes(Player activeChar) {
        this.handleRes(activeChar, null);
    }

    private void handleRes(Player activeChar, String player) {
        GameObject obj = activeChar.getTarget();
        if (player != null) {
            Player plyr = World.getPlayer(player);
            if (plyr != null) {
                obj = plyr;
            } else {
                try {
                    int radius = Math.max(Integer.parseInt(player), 100);
                    for (Creature character : activeChar.getAroundCharacters(radius, radius)) {
                        this.handleRes(character);
                    }
                    activeChar.sendMessage("Resurrected within " + radius + " unit radius.");
                    return;
                }
                catch (NumberFormatException e) {
                    activeChar.sendMessage("Enter valid player name or radius");
                    return;
                }
            }
        }
        if (obj == null) {
            obj = activeChar;
        }
        if (obj instanceof Creature) {
            this.handleRes((Creature)obj);
        } else {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
        }
    }

    private void handleRes(Creature target) {
        if (!target.isDead()) {
            return;
        }
        if (target.isPlayable()) {
            if (target.isPlayer()) {
                ((Player)target).doRevive(100.0);
            } else {
                ((Playable)target).doRevive();
            }
        } else if (target.isNpc()) {
            ((NpcInstance)target).stopDecay();
        }
        target.setCurrentHpMp(target.getMaxHp(), target.getMaxMp(), true);
        target.setCurrentCp(target.getMaxCp());
    }

    private static enum Commands {
        admin_res;

    }
}

