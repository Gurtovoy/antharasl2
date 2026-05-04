/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.tables;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class GmListTable {
    public static List<Player> getAllGMs() {
        ArrayList<Player> gmList = new ArrayList<Player>();
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            if (!player.isGM()) continue;
            gmList.add(player);
        }
        return gmList;
    }

    public static List<Player> getAllVisibleGMs() {
        ArrayList<Player> gmList = new ArrayList<Player>();
        for (Player player : GameObjectsStorage.getPlayers(false, false)) {
            if (!player.isGM() || player.isGMInvisible() || Config.HIDE_GM_STATUS) continue;
            gmList.add(player);
        }
        return gmList;
    }

    public static void sendListToPlayer(Player player) {
        List<Player> gmList = GmListTable.getAllVisibleGMs();
        if (gmList.isEmpty()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NO_GMS_CURRENTLY_VISIBLE_IN_THE_PUBLIC_LIST_AS_THEY_MAY_BE_PERFORMING_OTHER_FUNCTIONS_AT_THE_MOMENT);
            return;
        }
        player.sendPacket((IBroadcastPacket)SystemMsg.GM_LIST);
        for (Player gm : gmList) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.GM__C1).addName(gm));
        }
    }

    public static void broadcastToGMs(L2GameServerPacket packet) {
        for (Player gm : GmListTable.getAllGMs()) {
            gm.sendPacket((IBroadcastPacket)packet);
        }
    }

    public static void broadcastMessageToGMs(String message) {
        for (Player gm : GmListTable.getAllGMs()) {
            gm.sendMessage(message);
        }
    }
}

