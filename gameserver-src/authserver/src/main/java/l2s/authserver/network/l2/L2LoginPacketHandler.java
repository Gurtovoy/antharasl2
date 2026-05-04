package l2s.authserver.network.l2;

import java.nio.ByteBuffer;
import l2s.authserver.network.l2.L2LoginClient;
import l2s.authserver.network.l2.c2s.AuthGameGuard;
import l2s.authserver.network.l2.c2s.L2LoginClientPacket;
import l2s.authserver.network.l2.c2s.RequestAuthLogin;
import l2s.authserver.network.l2.c2s.RequestServerList;
import l2s.authserver.network.l2.c2s.RequestServerLogin;
import l2s.commons.net.nio.impl.IPacketHandler;
import l2s.commons.net.nio.impl.ReceivablePacket;

public final class L2LoginPacketHandler
implements IPacketHandler<L2LoginClient> {
    public ReceivablePacket<L2LoginClient> handlePacket(ByteBuffer buf, L2LoginClient client) {
        int opcode = buf.get() & 0xFF;
        L2LoginClientPacket packet = null;
        L2LoginClient.LoginClientState state = client.getState();
        switch (state) {
            case CONNECTED: {
                if (opcode != 7) break;
                packet = new AuthGameGuard();
                break;
            }
            case AUTHED_GG: {
                if (opcode != 0) break;
                packet = new RequestAuthLogin();
                break;
            }
            case AUTHED: {
                if (opcode == 5) {
                    packet = new RequestServerList();
                    break;
                }
                if (opcode != 2) break;
                packet = new RequestServerLogin();
            }
        }
        return packet;
    }
}

