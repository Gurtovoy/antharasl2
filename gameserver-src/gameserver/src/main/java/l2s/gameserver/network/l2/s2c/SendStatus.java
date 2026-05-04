/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Calendar;
import java.util.Locale;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class SendStatus
extends L2GameServerPacket {
    private static final long MIN_UPDATE_PERIOD = 30000L;
    private static int online_players = 0;
    private static int max_online_players = 0;
    private static int online_priv_store = 0;
    private static long last_update = 0L;

    public SendStatus() {
        if (System.currentTimeMillis() - last_update < 30000L) {
            return;
        }
        last_update = System.currentTimeMillis();
        if (!Config.ENABLE_L2_TOP_OVERONLINE) {
            int i = 0;
            int j = 0;
            for (Player player : GameObjectsStorage.getPlayers(false, true)) {
                ++i;
                if (!player.isInStoreMode() || Config.SENDSTATUS_TRADE_JUST_OFFLINE && !player.isInOfflineMode()) continue;
                ++j;
            }
            online_players = i;
            online_priv_store = (int)Math.floor((double)j * Config.SENDSTATUS_TRADE_MOD);
            max_online_players = Math.max(max_online_players, online_players);
        } else {
            max_online_players = Config.L2TOP_MAX_ONLINE;
            int hour = Calendar.getInstance(new Locale("ru", "RU")).get(11);
            online_players = hour >= 0 && hour < 6 ? Rnd.get((int)Config.MIN_ONLINE_0_5_AM, (int)Config.MAX_ONLINE_0_5_AM) : (hour >= 6 && hour < 12 ? Rnd.get((int)Config.MIN_ONLINE_6_11_AM, (int)Config.MAX_ONLINE_6_11_AM) : (hour >= 12 && hour < 19 ? Rnd.get((int)Config.MIN_ONLINE_12_6_PM, (int)Config.MAX_ONLINE_12_6_PM) : Rnd.get((int)Config.MIN_ONLINE_7_11_PM, (int)Config.MAX_ONLINE_7_11_PM)));
            int weekDay = Calendar.getInstance().get(7) + 1;
            online_players += weekDay < 5 ? Config.ADD_ONLINE_ON_SIMPLE_DAY : Config.ADD_ONLINE_ON_WEEKEND;
            online_priv_store = Rnd.get((int)Config.L2TOP_MIN_TRADERS, (int)Config.L2TOP_MAX_TRADERS);
        }
    }

    @Override
    protected final boolean writeOpcodes() {
        this.writeC(0);
        return true;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(1);
        this.writeD(max_online_players);
        this.writeD(online_players);
        this.writeD(online_players);
        this.writeD(online_priv_store);
        this.writeD(2883632);
        for (int x = 0; x < 10; ++x) {
            this.writeH(41 + Rnd.get((int)17));
        }
        this.writeD(43 + Rnd.get((int)17));
        int z = 36219 + Rnd.get((int)1987);
        this.writeD(z);
        this.writeD(z);
        this.writeD(37211 + Rnd.get((int)2397));
        this.writeD(0);
        this.writeD(2);
    }
}

