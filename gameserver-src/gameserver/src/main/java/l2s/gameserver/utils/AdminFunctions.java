/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.utils;

import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.utils.AutoBan;
import l2s.gameserver.utils.Log;

public final class AdminFunctions {
    public static final Location JAIL_SPAWN = new Location(-114648, -249384, -2984);

    private AdminFunctions() {
    }

    public static boolean kick(String player, String reason) {
        Player plyr = World.getPlayer(player);
        if (plyr == null) {
            return false;
        }
        return AdminFunctions.kick(plyr, reason);
    }

    public static boolean kick(Player player, String reason) {
        player.kick();
        return true;
    }

    public static String banChat(Player adminChar, String adminName, String charName, int val, String reason) {
        String result;
        Player player = World.getPlayer(charName);
        if (player != null) {
            charName = player.getName();
        } else if (CharacterDAO.getInstance().getObjectIdByName(charName) == 0) {
            return "\u0418\u0433\u0440\u043e\u043a " + charName + " \u043d\u0435 \u043d\u0430\u0439\u0434\u0435\u043d.";
        }
        if ((adminName == null || adminName.isEmpty()) && adminChar != null) {
            adminName = adminChar.getName();
        }
        if (reason == null || reason.isEmpty()) {
            reason = "\u043d\u0435 \u0443\u043a\u0430\u0437\u0430\u043d\u0430";
        }
        String announce = null;
        if (val == 0) {
            if (adminChar != null && !adminChar.getPlayerAccess().CanUnBanChat) {
                return "\u0412\u044b \u043d\u0435 \u0438\u043c\u0435\u0435\u0442\u0435 \u043f\u0440\u0430\u0432 \u043d\u0430 \u0441\u043d\u044f\u0442\u0438\u0435 \u0431\u0430\u043d\u0430 \u0447\u0430\u0442\u0430.";
            }
            if (Config.BANCHAT_ANNOUNCE) {
                announce = Config.BANCHAT_ANNOUNCE_NICK && adminName != null && !adminName.isEmpty() ? adminName + " \u0441\u043d\u044f\u043b \u0431\u0430\u043d \u0447\u0430\u0442\u0430 \u0441 \u0438\u0433\u0440\u043e\u043a\u0430 " + charName + "." : "\u0421 \u0438\u0433\u0440\u043e\u043a\u0430 " + charName + " \u0441\u043d\u044f\u0442 \u0431\u0430\u043d \u0447\u0430\u0442\u0430.";
            }
            Log.add(adminName + " \u0441\u043d\u044f\u043b \u0431\u0430\u043d \u0447\u0430\u0442\u0430 \u0441 \u0438\u0433\u0440\u043e\u043a\u0430 " + charName + ".", "banchat", adminChar);
            result = "\u0412\u044b \u0441\u043d\u044f\u043b\u0438 \u0431\u0430\u043d \u0447\u0430\u0442\u0430 \u0441 \u0438\u0433\u0440\u043e\u043a\u0430 " + charName + ".";
        } else if (val < 0) {
            if (adminChar != null && adminChar.getPlayerAccess().BanChatMaxValue > 0) {
                return "\u0412\u044b \u043c\u043e\u0436\u0435\u0442\u0435 \u0431\u0430\u043d\u0438\u0442\u044c \u043d\u0435 \u0431\u043e\u043b\u0435\u0435 \u0447\u0435\u043c \u043d\u0430 " + adminChar.getPlayerAccess().BanChatMaxValue + " \u043c\u0438\u043d\u0443\u0442.";
            }
            if (Config.BANCHAT_ANNOUNCE) {
                announce = Config.BANCHAT_ANNOUNCE_NICK && adminName != null && !adminName.isEmpty() ? adminName + " \u0437\u0430\u0431\u0430\u043d\u0438\u043b \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 \u0431\u0435\u0441\u0441\u0440\u043e\u0447\u043d\u044b\u0439 \u043f\u0435\u0440\u0438\u043e\u0434, \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + "." : "\u0417\u0430\u0431\u0430\u043d\u0435\u043d \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 \u0431\u0435\u0441\u0441\u0440\u043e\u0447\u043d\u044b\u0439 \u043f\u0435\u0440\u0438\u043e\u0434, \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + ".";
            }
            Log.add(adminName + " \u0437\u0430\u0431\u0430\u043d\u0438\u043b \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 \u0431\u0435\u0441\u0441\u0440\u043e\u0447\u043d\u044b\u0439 \u043f\u0435\u0440\u0438\u043e\u0434, \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + ".", "banchat", adminChar);
            result = "\u0412\u044b \u0437\u0430\u0431\u0430\u043d\u0438\u043b\u0438 \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 \u0431\u0435\u0441\u0441\u0440\u043e\u0447\u043d\u044b\u0439 \u043f\u0435\u0440\u0438\u043e\u0434.";
        } else {
            if (!(adminChar == null || adminChar.getPlayerAccess().CanUnBanChat || player != null && player.getNoChannel() == 0L)) {
                return "\u0412\u044b \u043d\u0435 \u0438\u043c\u0435\u0435\u0442\u0435 \u043f\u0440\u0430\u0432\u0430 \u0438\u0437\u043c\u0435\u043d\u044f\u0442\u044c \u0432\u0440\u0435\u043c\u044f \u0431\u0430\u043d\u0430.";
            }
            if (adminChar != null && adminChar.getPlayerAccess().BanChatMaxValue != -1 && val > adminChar.getPlayerAccess().BanChatMaxValue) {
                return "\u0412\u044b \u043c\u043e\u0436\u0435\u0442\u0435 \u0431\u0430\u043d\u0438\u0442\u044c \u043d\u0435 \u0431\u043e\u043b\u0435\u0435 \u0447\u0435\u043c \u043d\u0430 " + adminChar.getPlayerAccess().BanChatMaxValue + " \u043c\u0438\u043d\u0443\u0442.";
            }
            if (Config.BANCHAT_ANNOUNCE) {
                announce = Config.BANCHAT_ANNOUNCE_NICK && adminName != null && !adminName.isEmpty() ? adminName + " \u0437\u0430\u0431\u0430\u043d\u0438\u043b \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 " + val + " \u043c\u0438\u043d\u0443\u0442, \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + "." : "\u0417\u0430\u0431\u0430\u043d\u0435\u043d \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 " + val + " \u043c\u0438\u043d\u0443\u0442, \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + ".";
            }
            Log.add(adminName + " \u0437\u0430\u0431\u0430\u043d\u0438\u043b \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 " + val + " \u043c\u0438\u043d\u0443\u0442, \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + ".", "banchat", adminChar);
            result = "\u0412\u044b \u0437\u0430\u0431\u0430\u043d\u0438\u043b\u0438 \u0447\u0430\u0442 \u0438\u0433\u0440\u043e\u043a\u0443 " + charName + " \u043d\u0430 " + val + " \u043c\u0438\u043d\u0443\u0442.";
        }
        if (player != null) {
            AdminFunctions.updateNoChannel(player, val, reason);
        } else {
            AutoBan.ChatBan(charName, val, reason, adminName);
        }
        if (announce != null) {
            if (Config.BANCHAT_ANNOUNCE_FOR_ALL_WORLD) {
                Announcements.announceToAll(announce);
            } else {
                Announcements.shout(adminChar, announce, ChatType.CRITICAL_ANNOUNCE);
            }
        }
        return result;
    }

    private static void updateNoChannel(Player player, int time, String reason) {
        player.updateNoChannel(time * 60000);
        if (time < 0) {
            player.broadcastPrivateStoreInfo();
        }
        if (time == 0) {
            player.sendMessage(new CustomMessage("common.ChatUnBanned"));
        } else if (time > 0) {
            if (reason == null || reason.isEmpty()) {
                player.sendMessage(new CustomMessage("common.ChatBanned").addNumber(time));
            } else {
                player.sendMessage(new CustomMessage("common.ChatBannedWithReason").addNumber(time).addString(reason));
            }
        } else if (reason == null || reason.isEmpty()) {
            player.sendMessage(new CustomMessage("common.ChatBannedPermanently"));
        } else {
            player.sendMessage(new CustomMessage("common.ChatBannedPermanentlyWithReason").addString(reason));
        }
    }
}

