/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.instancemanager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.ban.BanBindType;
import l2s.commons.ban.BanInfo;
import l2s.commons.ban.BanManager;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.GameBansDAO;
import l2s.gameserver.listener.actor.player.OnPlayerEnterListener;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.listener.CharListenerList;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ServerCloseSocketPacket;
import l2s.gameserver.utils.TimeUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameBanManager
extends BanManager {
    private static final GameBanManager INSTANCE = new GameBanManager();
    private static final Logger LOGGER = LoggerFactory.getLogger(GameBanManager.class);
    private final Lock lock = new ReentrantLock();
    private final BanListeners listeners = new BanListeners();
    private ScheduledFuture<?> checkBansTask = null;

    public static GameBanManager getInstance() {
        return INSTANCE;
    }

    public void init() {
        GameBansDAO.getInstance().cleanUp();
        this.startCheckBansTask();
        CharListenerList.addGlobal(this.listeners);
        LOGGER.info("GameBanManager: Initialized.");
    }

    private void startCheckBansTask() {
        if (this.checkBansTask != null) {
            return;
        }
        long interval = TimeUnit.MINUTES.toMillis(Config.CHECK_BANS_INTERVAL);
        this.checkBansTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> this.checkBans(), 0L, interval);
    }

    
    private void checkBans() {
        this.lock.lock();
        try {
            for (BanBindType bindType : BanBindType.VALUES) {
                if (!bindType.isGame()) continue;
                HashMap<String, BanInfo> bans = new HashMap<String, BanInfo>();
                GameBansDAO.getInstance().select(bans, bindType);
                for (Map.Entry entry : bans.entrySet()) {
                    GameBanManager.onBan(bindType, entry.getKey(), (BanInfo)entry.getValue(), false);
                }
                this.getCachedBans().put(bindType, bans);
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    
    public boolean giveBan(BanBindType bindType, String bindValue, int endTime, String reason) {
        if (!bindType.isGame()) {
            return false;
        }
        if (StringUtils.isEmpty((CharSequence)bindValue)) {
            return false;
        }
        if (endTime != -1 && (long)endTime < System.currentTimeMillis() / 1000L) {
            return false;
        }
        this.lock.lock();
        try {
            BanInfo banInfo = new BanInfo(endTime, reason);
            if (!GameBansDAO.getInstance().insert(bindType, bindValue, banInfo)) {
                boolean bl = false;
                return bl;
            }
            this.getCachedBans().computeIfAbsent(bindType, b -> new HashMap()).put(bindValue, banInfo);
            GameBanManager.onBan(bindType, bindValue, banInfo, false);
        }
        finally {
            this.lock.unlock();
        }
        return true;
    }

    
    public boolean removeBan(BanBindType bindType, String bindValue) {
        if (!bindType.isGame()) {
            return false;
        }
        if (StringUtils.isEmpty((CharSequence)bindValue)) {
            return false;
        }
        this.lock.lock();
        try {
            Map bans = (Map)this.getCachedBans().get(bindType);
            if (bans == null) {
                boolean bl = false;
                return bl;
            }
            if (!GameBansDAO.getInstance().delete(bindType, bindValue)) {
                boolean bl = false;
                return bl;
            }
            bans.remove(bindValue);
            GameBanManager.onUnban(bindType, bindValue, false);
            boolean bl = true;
            return bl;
        }
        finally {
            this.lock.unlock();
        }
    }

    public static void onBan(BanBindType bindType, Object bindValueObj, BanInfo banInfo, boolean auth) {
        if (auth && !bindType.isAuth() || !auth && !bindType.isGame()) {
            return;
        }
        int endTime = banInfo.getEndTime();
        if (endTime != -1 && (long)endTime < System.currentTimeMillis() / 1000L) {
            return;
        }
        String bindValue = String.valueOf(bindValueObj);
        ArrayList<GameClient> gameClients = new ArrayList<GameClient>();
        if (bindType == BanBindType.LOGIN) {
            GameClient client = AuthServerCommunication.getInstance().getWaitingClient(bindValue);
            if (client != null) {
                gameClients.add(client);
            }
            if ((client = AuthServerCommunication.getInstance().getAuthedClient(bindValue)) != null) {
                gameClients.add(client);
            }
        } else if (bindType == BanBindType.IP) {
            gameClients.addAll(AuthServerCommunication.getInstance().getWaitingClientsByIP(bindValue));
            gameClients.addAll(AuthServerCommunication.getInstance().getAuthedClientsByIP(bindValue));
        } else if (bindType == BanBindType.HWID) {
            gameClients.addAll(AuthServerCommunication.getInstance().getWaitingClientsByHWID(bindValue));
            gameClients.addAll(AuthServerCommunication.getInstance().getAuthedClientsByHWID(bindValue));
        } else if (bindType == BanBindType.PLAYER) {
            Player player = GameObjectsStorage.getPlayer(Integer.parseInt(bindValue));
            if (player == null) {
                return;
            }
            GameClient gameClient = player.getNetConnection();
            if (gameClient == null) {
                return;
            }
            gameClients.add(gameClient);
        } else if (bindType == BanBindType.CHAT) {
            Player player = GameObjectsStorage.getPlayer(Integer.parseInt(bindValue));
            if (player == null) {
                return;
            }
            if (!player.startBanEndTask(bindType, endTime)) {
                return;
            }
            CustomMessage banMsg = new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.game.banned.chat");
            CustomMessage endTimeMsg = new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.endtime");
            CustomMessage reasonMsg = null;
            endTimeMsg = endTime != -1 ? endTimeMsg.addString(TimeUtils.toSimpleFormat((long)endTime * 1000L)) : endTimeMsg.addCustomMessage(new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.never"));
            String reason = banInfo.getReason();
            if (!StringUtils.isEmpty((CharSequence)reason)) {
                reasonMsg = new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.reason").addString(reason);
            }
            player.sendPacket((IBroadcastPacket)banMsg);
            if (reasonMsg != null) {
                player.sendPacket((IBroadcastPacket)reasonMsg);
            }
            if (endTimeMsg != null) {
                player.sendPacket((IBroadcastPacket)endTimeMsg);
            }
            return;
        }
        if (gameClients.isEmpty()) {
            return;
        }
        CustomMessage banMsg = new CustomMessage(String.format("l2s.gameserver.instancemanager.GameBanManager.%s.banned.%s", auth ? "auth" : "game", bindType.toString().toLowerCase()));
        CustomMessage endTimeMsg = new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.endtime");
        CustomMessage reasonMsg = null;
        endTimeMsg = endTime != -1 ? endTimeMsg.addString(TimeUtils.toSimpleFormat((long)endTime * 1000L)) : endTimeMsg.addCustomMessage(new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.never"));
        String reason = banInfo.getReason();
        if (!StringUtils.isEmpty((CharSequence)reason)) {
            reasonMsg = new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.reason").addString(reason);
        }
        for (GameClient gameClient : gameClients) {
            AuthServerCommunication.getInstance().removeClient(gameClient);
            Player activeChar = gameClient.getActiveChar();
            if (activeChar != null) {
                activeChar.sendPacket((IBroadcastPacket)banMsg);
                if (reasonMsg != null) {
                    activeChar.sendPacket((IBroadcastPacket)reasonMsg);
                }
                if (endTimeMsg != null) {
                    activeChar.sendPacket((IBroadcastPacket)endTimeMsg);
                }
                ThreadPoolManager.getInstance().schedule(() -> activeChar.kick(), 500L);
                continue;
            }
            gameClient.close(ServerCloseSocketPacket.STATIC);
        }
    }

    public static void onUnban(BanBindType bindType, Object bindValueObj, boolean auth) {
        Player player;
        if (auth && !bindType.isAuth() || !auth && !bindType.isGame()) {
            return;
        }
        String bindValue = String.valueOf(bindValueObj);
        if (bindType == BanBindType.CHAT && (player = GameObjectsStorage.getPlayer(Integer.parseInt(bindValue))) != null) {
            player.stopBanEndTask(bindType);
            player.sendPacket((IBroadcastPacket)new CustomMessage("l2s.gameserver.instancemanager.GameBanManager.game.unbanned.chat"));
        }
    }

    private class BanListeners
    implements OnPlayerEnterListener {
        private BanListeners() {
        }

        @Override
        public void onPlayerEnter(Player player) {
            BanInfo banInfo = GameBanManager.this.getBanInfoIfBanned(BanBindType.CHAT, player.getObjectId());
            if (banInfo == null) {
                return;
            }
            GameBanManager.onBan(BanBindType.CHAT, player.getObjectId(), banInfo, false);
        }
    }
}

