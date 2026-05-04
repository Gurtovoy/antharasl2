package l2s.authserver;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.authserver.Config;
import l2s.authserver.ThreadPoolManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class IpBanManager {
    private static final Logger _log = LoggerFactory.getLogger(IpBanManager.class);
    private static final IpBanManager _instance = new IpBanManager();
    private final Map<String, IpSession> ips = new HashMap<String, IpSession>();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();

    public static final IpBanManager getInstance() {
        return _instance;
    }

    private IpBanManager() {
        ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> {
            long currentMillis = System.currentTimeMillis();
            this.writeLock.lock();
            try {
                Iterator<IpSession> itr = this.ips.values().iterator();
                while (itr.hasNext()) {
                    IpSession session = itr.next();
                    if (session.banExpire >= currentMillis || session.lastTry >= currentMillis - Config.LOGIN_TRY_TIMEOUT) continue;
                    itr.remove();
                }
            }
            finally {
                this.writeLock.unlock();
            }
        }, 1000L, 1000L);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean isIpBanned(String ip) {
        this.readLock.lock();
        try {
            IpSession ipsession = this.ips.get(ip);
            if (ipsession == null) {
                boolean bl = false;
                return bl;
            }
            boolean bl = ipsession.banExpire > System.currentTimeMillis();
            return bl;
        }
        finally {
            this.readLock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean tryLogin(String ip, boolean success) {
        this.writeLock.lock();
        try {
            long currentMillis;
            IpSession ipsession = this.ips.get(ip);
            if (ipsession == null) {
                ipsession = new IpSession();
                this.ips.put(ip, ipsession);
            }
            if ((currentMillis = System.currentTimeMillis()) - ipsession.lastTry < Config.LOGIN_TRY_TIMEOUT) {
                success = false;
            }
            if (success) {
                if (ipsession.tryCount > 0) {
                    --ipsession.tryCount;
                }
            } else if (ipsession.tryCount < Config.LOGIN_TRY_BEFORE_BAN) {
                ++ipsession.tryCount;
            }
            ipsession.lastTry = currentMillis;
            if (ipsession.tryCount == Config.LOGIN_TRY_BEFORE_BAN) {
                _log.warn("IpBanManager: " + ip + " banned for " + Config.IP_BAN_TIME / 1000L + " seconds.");
                ipsession.banExpire = currentMillis + Config.IP_BAN_TIME;
                boolean bl = false;
                return bl;
            }
            boolean bl = true;
            return bl;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    private class IpSession {
        public int tryCount;
        public long lastTry;
        public long banExpire;

        private IpSession() {
        }
    }
}

