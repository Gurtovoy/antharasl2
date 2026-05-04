package l2s.authserver.accounts;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.authserver.ThreadPoolManager;
import l2s.authserver.accounts.Account;
import l2s.authserver.network.l2.SessionKey;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SessionManager {
    private static final Logger _log = LoggerFactory.getLogger(SessionManager.class);
    private static final SessionManager _instance = new SessionManager();
    private final Map<SessionKey, Session> sessions = new HashMap<SessionKey, Session>();
    private final Lock lock = new ReentrantLock();

    public static final SessionManager getInstance() {
        return _instance;
    }

    private SessionManager() {
        ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> {
            this.lock.lock();
            try {
                long currentMillis = System.currentTimeMillis();
                Iterator<Session> itr = this.sessions.values().iterator();
                while (itr.hasNext()) {
                    Session session = itr.next();
                    if (session.getExpireTime() >= currentMillis) continue;
                    itr.remove();
                }
            }
            finally {
                this.lock.unlock();
            }
        }, 30000L, 30000L);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Session openSession(Account account) {
        this.lock.lock();
        try {
            Session session = new Session(account);
            this.sessions.put(session.getSessionKey(), session);
            Session session2 = session;
            return session2;
        }
        finally {
            this.lock.unlock();
        }
    }

    public Session closeSession(SessionKey skey) {
        this.lock.lock();
        try {
            Session session = this.sessions.remove(skey);
            return session;
        }
        finally {
            this.lock.unlock();
        }
    }

    public Session getSessionByName(String name) {
        for (Session session : this.sessions.values()) {
            if (!session.account.getLogin().equalsIgnoreCase(name)) continue;
            return session;
        }
        return null;
    }

    public final class Session {
        private final Account account;
        private final SessionKey skey;
        private final long expireTime;

        private Session(Account account) {
            this.account = account;
            this.skey = SessionKey.create();
            this.expireTime = System.currentTimeMillis() + 60000L;
        }

        public SessionKey getSessionKey() {
            return this.skey;
        }

        public Account getAccount() {
            return this.account;
        }

        public long getExpireTime() {
            return this.expireTime;
        }
    }
}

