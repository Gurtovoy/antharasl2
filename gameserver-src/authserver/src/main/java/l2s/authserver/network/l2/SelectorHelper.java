package l2s.authserver.network.l2;

import java.nio.channels.SocketChannel;
import l2s.authserver.IpBanManager;
import l2s.authserver.ThreadPoolManager;
import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.s2c.Init;
import l2s.commons.net.nio.impl.IAcceptFilter;
import l2s.commons.net.nio.impl.IClientFactory;
import l2s.commons.net.nio.impl.IMMOExecutor;
import l2s.commons.net.nio.impl.MMOConnection;

public class SelectorHelper
implements IMMOExecutor<L2LoginClient>,
IClientFactory<L2LoginClient>,
IAcceptFilter {
    public void execute(Runnable r) {
        ThreadPoolManager.getInstance().execute(r);
    }

    public L2LoginClient create(MMOConnection<L2LoginClient> con) {
        L2LoginClient client = new L2LoginClient(con);
        client.sendPacket(new Init(client));
        ThreadPoolManager.getInstance().schedule(() -> client.closeNow(false), 60000L);
        return client;
    }

    public boolean accept(SocketChannel sc) {
        return !IpBanManager.getInstance().isIpBanned(sc.socket().getInetAddress().getHostAddress());
    }
}

