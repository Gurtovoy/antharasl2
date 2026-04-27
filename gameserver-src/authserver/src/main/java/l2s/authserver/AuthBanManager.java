/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.ban.BanBindType
 *  l2s.commons.ban.BanInfo
 *  l2s.commons.ban.BanManager
 *  org.apache.commons.lang3.StringUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.authserver.Config;
import l2s.authserver.GameServerManager;
import l2s.authserver.ThreadPoolManager;
import l2s.authserver.dao.AuthBansDAO;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.as2gs.CheckBans;
import l2s.commons.ban.BanBindType;
import l2s.commons.ban.BanInfo;
import l2s.commons.ban.BanManager;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthBanManager
extends BanManager {
    private static final AuthBanManager INSTANCE = new AuthBanManager();
    private static final Logger LOGGER = LoggerFactory.getLogger(AuthBanManager.class);
    private final Lock lock = new ReentrantLock();
    private ScheduledFuture<?> checkBansTask = null;

    public static AuthBanManager getInstance() {
        return INSTANCE;
    }

    public void init() {
        AuthBansDAO.getInstance().cleanUp();
        this.startCheckBansTask();
        LOGGER.info("AuthBanManager: Initialized.");
    }

    private void startCheckBansTask() {
        if (this.checkBansTask != null) {
            return;
        }
        long interval = TimeUnit.MINUTES.toMillis(Config.CHECK_BANS_INTERVAL);
        this.checkBansTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> this.checkBans(), 0L, interval);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void checkBans() {
        this.lock.lock();
        try {
            for (BanBindType bindType : BanBindType.VALUES) {
                if (!bindType.isAuth()) continue;
                HashMap<String, BanInfo> bans = new HashMap<String, BanInfo>();
                AuthBansDAO.getInstance().select(bans, bindType);
                CheckBans checkBans = new CheckBans(bindType, bans);
                for (GameServer gameServer : GameServerManager.getInstance().getGameServers()) {
                    gameServer.sendPacket(checkBans);
                }
                this.getCachedBans().put(bindType, bans);
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean giveBan(BanBindType bindType, String bindValue, int endTime, String reason) {
        if (!bindType.isAuth()) {
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
            if (!AuthBansDAO.getInstance().insert(bindType, bindValue, banInfo)) {
                boolean bl = false;
                return bl;
            }
            this.getCachedBans().computeIfAbsent(bindType, b -> new HashMap()).put(bindValue, banInfo);
        }
        finally {
            this.lock.unlock();
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean removeBan(BanBindType bindType, String bindValue) {
        if (!bindType.isAuth()) {
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
            if (!AuthBansDAO.getInstance().delete(bindType, bindValue)) {
                boolean bl = false;
                return bl;
            }
            bans.remove(bindValue);
            boolean bl = true;
            return bl;
        }
        finally {
            this.lock.unlock();
        }
    }
}

