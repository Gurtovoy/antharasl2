/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.utils;

import java.util.Map;
import l2s.gameserver.instancemanager.ServerVariables;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExNoticePostArrived;
import l2s.gameserver.network.l2.s2c.ExUnReadMailCount;
import l2s.gameserver.network.l2.s2c.NSPacket;
import l2s.gameserver.utils.ChatUtils;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.ItemFunctions;

public class Functions {
    public static void show(String text, Player player) {
        Functions.show(text, player, 0, new Object[0]);
    }

    public static void show(CustomMessage message, Player player) {
        Functions.show(message.toString(player), player, 0, new Object[0]);
    }

    public static void show(String text, Player player, int itemId, Object ... arg) {
        if (text == null || player == null) {
            return;
        }
        HtmlMessage msg = new HtmlMessage(5);
        if (text.endsWith(".html") || text.endsWith(".htm")) {
            msg.setFile(text);
        } else {
            msg.setHtml(HtmlUtils.bbParse(text));
        }
        if (arg != null && arg.length % 2 == 0) {
            int i = 0;
            while (i < arg.length) {
                msg.replace(String.valueOf(arg[i]), String.valueOf(arg[i + 1]));
                i = 2;
            }
        }
        msg.setItemId(itemId);
        player.sendPacket((IBroadcastPacket)msg);
    }

    public static void show(String text, Player player, NpcInstance npc, Object ... arg) {
        if (text == null || player == null) {
            return;
        }
        HtmlMessage msg = new HtmlMessage(npc);
        if (text.endsWith(".html") || text.endsWith(".htm")) {
            msg.setFile(text);
        } else {
            msg.setHtml(HtmlUtils.bbParse(text));
        }
        if (arg != null && arg.length % 2 == 0) {
            int i = 0;
            while (i < arg.length) {
                msg.replace(String.valueOf(arg[i]), String.valueOf(arg[i + 1]));
                i = 2;
            }
        }
        player.sendPacket((IBroadcastPacket)msg);
    }

    public static void npcSayInRange(NpcInstance npc, String text, int range) {
        Functions.npcSayInRange(npc, range, NpcString.NONE, text);
    }

    public static void npcSayInRange(NpcInstance npc, int range, NpcString fStringId, String ... params) {
        ChatUtils.say(npc, range, new NSPacket(npc, ChatType.NPC_ALL, fStringId, params));
    }

    public static void npcSay(NpcInstance npc, String text) {
        Functions.npcSayInRange(npc, text, 1500);
    }

    public static void npcSay(NpcInstance npc, NpcString npcString, String ... params) {
        Functions.npcSayInRange(npc, 1500, npcString, params);
    }

    public static void npcSay(NpcInstance npc, Player player, NpcString npcString, String ... params) {
        player.sendPacket((IBroadcastPacket)new NSPacket(npc, ChatType.NPC_ALL, npcString, params));
    }

    public static void npcSayInRangeCustomMessage(NpcInstance npc, int range, String address, Object ... replacements) {
        CustomMessage cm = new CustomMessage(address);
        for (Object replacement : replacements) {
            if (replacement instanceof CustomMessage) {
                cm.addCustomMessage((CustomMessage)replacement);
                continue;
            }
            cm.addString(String.valueOf(replacement));
        }
        ChatUtils.say(npc, range, cm);
    }

    public static void npcSayCustomMessage(NpcInstance npc, String address, Object ... replacements) {
        Functions.npcSayInRangeCustomMessage(npc, 1500, address, replacements);
    }

    public static void npcSayToPlayer(NpcInstance npc, Player player, String text) {
        Functions.npcSayToPlayer(npc, player, NpcString.NONE, text);
    }

    public static void npcSayToPlayer(NpcInstance npc, Player player, NpcString npcString, String ... params) {
        player.sendPacket((IBroadcastPacket)new NSPacket(npc, ChatType.TELL, npcString, params));
    }

    public static void npcShout(NpcInstance npc, String text) {
        Functions.npcShout(npc, NpcString.NONE, text);
    }

    public static void npcShout(NpcInstance npc, NpcString npcString, String ... params) {
        ChatUtils.shout(npc, npcString, params);
    }

    public static void npcShoutCustomMessage(NpcInstance npc, String address, Object ... replacements) {
        CustomMessage cm = new CustomMessage(address);
        for (Object replacement : replacements) {
            if (replacement instanceof CustomMessage) {
                cm.addCustomMessage((CustomMessage)replacement);
                continue;
            }
            cm.addString(String.valueOf(replacement));
        }
        ChatUtils.shout(npc, cm);
    }

    public static void npcSay(NpcInstance npc, NpcString address, ChatType type, int range, String ... replacements) {
        ChatUtils.say(npc, range, new NSPacket(npc, type, address, replacements));
    }

    public static boolean ride(Player player, int npcId) {
        if (player.hasServitor()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ALREADY_HAVE_A_PET);
            return false;
        }
        player.setMount(0, npcId, player.getLevel(), -1);
        return true;
    }

    public static void unRide(Player player) {
        if (player.isMounted()) {
            player.setMount(null);
        }
    }

    public static void unSummonPet(Player player, boolean onlyPets) {
        for (Servitor servitor : player.getServitors()) {
            if (onlyPets && !servitor.isPet()) continue;
            servitor.unSummon(false);
        }
    }

    public static boolean IsActive(String name) {
        return ServerVariables.getString(name, "off").equalsIgnoreCase("on");
    }

    public static boolean SetActive(String name, boolean active) {
        if (active == Functions.IsActive(name)) {
            return false;
        }
        if (active) {
            ServerVariables.set(name, "on");
        } else {
            ServerVariables.unset(name);
        }
        return true;
    }

    public static boolean SimpleCheckDrop(Creature mob, Creature killer) {
        return mob != null && mob.isMonster() && !mob.isRaid() && killer != null && killer.getPlayer() != null && killer.getLevel() - mob.getLevel() < 9;
    }

    public static void sendDebugMessage(Player player, String message) {
        if (!player.isGM()) {
            return;
        }
        player.sendMessage(message);
    }

    public static void sendSystemMail(Player receiver, String title, String body, Map<Integer, Long> items) {
        if (receiver == null || !receiver.isOnline()) {
            return;
        }
        if (title == null) {
            return;
        }
        if (items.keySet().size() > 8) {
            return;
        }
        Mail mail = new Mail();
        mail.setSenderId(1);
        mail.setSenderName("Admin");
        mail.setReceiverId(receiver.getObjectId());
        mail.setReceiverName(receiver.getName());
        mail.setTopic(title);
        mail.setBody(body);
        for (Map.Entry<Integer, Long> itm : items.entrySet()) {
            ItemInstance item = ItemFunctions.createItem(itm.getKey());
            item.setLocation(ItemInstance.ItemLocation.MAIL);
            item.setCount(itm.getValue());
            item.save();
            mail.addAttachment(item);
        }
        mail.setType(Mail.SenderType.NEWS_INFORMER);
        mail.setUnread(true);
        mail.setExpireTime(2592000 + (int)(System.currentTimeMillis() / 1000L));
        mail.save();
        receiver.sendPacket((IBroadcastPacket)ExNoticePostArrived.STATIC_TRUE);
        receiver.sendPacket((IBroadcastPacket)new ExUnReadMailCount(receiver));
        receiver.sendPacket((IBroadcastPacket)SystemMsg.THE_MAIL_HAS_ARRIVED);
    }
}

