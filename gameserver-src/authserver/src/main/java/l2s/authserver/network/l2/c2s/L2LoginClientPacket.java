package l2s.authserver.network.l2.c2s;

import l2s.authserver.network.l2.L2LoginClient;
import l2s.commons.net.nio.impl.ReceivablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class L2LoginClientPacket
extends ReceivablePacket<L2LoginClient> {
    private static Logger _log = LoggerFactory.getLogger(L2LoginClientPacket.class);

    protected final boolean read() {
        try {
            return this.readImpl();
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
            return false;
        }
    }

    public void run() {
        try {
            this.runImpl();
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
    }

    protected abstract boolean readImpl();

    protected abstract void runImpl() throws Exception;
}

