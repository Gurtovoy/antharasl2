/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.authcomm;

import java.nio.ByteBuffer;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import l2s.gameserver.network.authcomm.as2gs.AuthResponse;
import l2s.gameserver.network.authcomm.as2gs.ChangePasswordResponse;
import l2s.gameserver.network.authcomm.as2gs.CheckBans;
import l2s.gameserver.network.authcomm.as2gs.GetAccountInfo;
import l2s.gameserver.network.authcomm.as2gs.KickPlayer;
import l2s.gameserver.network.authcomm.as2gs.LoginServerFail;
import l2s.gameserver.network.authcomm.as2gs.PingRequest;
import l2s.gameserver.network.authcomm.as2gs.PlayerAuthResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PacketHandler {
    private static final Logger _log = LoggerFactory.getLogger(PacketHandler.class);

    public static ReceivablePacket handlePacket(ByteBuffer buf) {
        ReceivablePacket packet = null;
        int id = buf.get() & 0xFF;
        switch (id) {
            case 0: {
                packet = new AuthResponse();
                break;
            }
            case 1: {
                packet = new LoginServerFail();
                break;
            }
            case 2: {
                packet = new PlayerAuthResponse();
                break;
            }
            case 3: {
                packet = new KickPlayer();
                break;
            }
            case 4: {
                packet = new GetAccountInfo();
                break;
            }
            case 6: {
                packet = new ChangePasswordResponse();
                break;
            }
            case 7: {
                packet = new CheckBans();
                break;
            }
            case 255: {
                packet = new PingRequest();
                break;
            }
            default: {
                _log.error("Received unknown packet: " + Integer.toHexString(id));
            }
        }
        return packet;
    }
}

