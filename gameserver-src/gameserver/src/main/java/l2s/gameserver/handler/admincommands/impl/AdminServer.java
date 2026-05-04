/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.admincommands.impl;

import java.lang.reflect.Field;
import l2s.gameserver.ai.CharacterAI;
import l2s.gameserver.ai.DefaultAI;
import l2s.gameserver.ai.NpcAI;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.instancemanager.ServerVariables;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.WorldRegion;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.RaidBossInstance;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;

public class AdminServer
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().Menu) {
            return false;
        }
        switch (command) {
            case admin_server: {
                try {
                    String val = fullString.substring(13);
                    AdminServer.showHelpPage(activeChar, val);
                }
                catch (StringIndexOutOfBoundsException e) {}
                break;
            }
            case admin_check_actor: {
                GameObject obj = activeChar.getTarget();
                if (obj == null) {
                    activeChar.sendMessage("target == null");
                    return false;
                }
                if (!obj.isCreature()) {
                    activeChar.sendMessage("target is not a character");
                    return false;
                }
                Creature target = (Creature)obj;
                CharacterAI ai = target.getAI();
                if (ai == null) {
                    activeChar.sendMessage("ai == null");
                    return false;
                }
                Creature actor = ai.getActor();
                if (actor == null) {
                    activeChar.sendMessage("actor == null");
                    return false;
                }
                activeChar.sendMessage("actor: " + actor);
                break;
            }
            case admin_setvar: {
                if (wordList.length != 3) {
                    activeChar.sendMessage("Incorrect argument count!!!");
                    return false;
                }
                ServerVariables.set(wordList[1], wordList[2]);
                activeChar.sendMessage("Value changed.");
                break;
            }
            case admin_set_ai_interval: {
                if (wordList.length != 2) {
                    activeChar.sendMessage("Incorrect argument count!!!");
                    return false;
                }
                int interval = Integer.parseInt(wordList[1]);
                int count = 0;
                int count2 = 0;
                for (NpcInstance npc : GameObjectsStorage.getNpcs()) {
                    NpcAI char_ai;
                    if (npc == null || npc instanceof RaidBossInstance || !((char_ai = npc.getAI()) instanceof DefaultAI)) continue;
                    try {
                        Field field = DefaultAI.class.getDeclaredField("AI_TASK_DELAY");
                        field.setAccessible(true);
                        field.set(char_ai, interval);
                        if (!((CharacterAI)char_ai).isActive()) continue;
                        ((CharacterAI)char_ai).stopAITask();
                        ++count;
                        WorldRegion region = npc.getCurrentRegion();
                        if (region == null || !region.isActive()) continue;
                        ((CharacterAI)char_ai).startAITask();
                        ++count2;
                    }
                    catch (Exception e) {}
                }
                activeChar.sendMessage(count + " AI stopped, " + count2 + " AI started");
            }
        }
        return true;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    public static void showHelpPage(Player targetChar, String filename) {
        HtmlMessage adminReply = new HtmlMessage(5);
        adminReply.setFile("admin/" + filename);
        targetChar.sendPacket((IBroadcastPacket)adminReply);
    }

    private static enum Commands {
        admin_server,
        admin_check_actor,
        admin_setvar,
        admin_set_ai_interval;

    }
}

