/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver.network.gamecomm;

import java.nio.ByteBuffer;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.authserver.network.gamecomm.gs2as.AuthRequest;
import l2s.authserver.network.gamecomm.gs2as.BanRequest;
import l2s.authserver.network.gamecomm.gs2as.BonusRequest;
import l2s.authserver.network.gamecomm.gs2as.ChangeAccessLevel;
import l2s.authserver.network.gamecomm.gs2as.ChangeAllowedHwid;
import l2s.authserver.network.gamecomm.gs2as.ChangeAllowedIp;
import l2s.authserver.network.gamecomm.gs2as.ChangePassword;
import l2s.authserver.network.gamecomm.gs2as.ChangePhoneNumber;
import l2s.authserver.network.gamecomm.gs2as.LockAccountIP;
import l2s.authserver.network.gamecomm.gs2as.OnlineStatus;
import l2s.authserver.network.gamecomm.gs2as.PingResponse;
import l2s.authserver.network.gamecomm.gs2as.PlayerAuthRequest;
import l2s.authserver.network.gamecomm.gs2as.PlayerInGame;
import l2s.authserver.network.gamecomm.gs2as.PlayerLogout;
import l2s.authserver.network.gamecomm.gs2as.ReduceAccountPoints;
import l2s.authserver.network.gamecomm.gs2as.SetAccountInfo;
import l2s.authserver.network.gamecomm.gs2as.UnbanRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PacketHandler {
    private static Logger _log = LoggerFactory.getLogger(PacketHandler.class);

    public static ReceivablePacket handlePacket(GameServer gs, ByteBuffer buf) {
        ReceivablePacket packet = null;
        int id = buf.get() & 0xFF;
        if (!gs.isAuthed()) {
            switch (id) {
                case 0: {
                    packet = new AuthRequest();
                    break;
                }
                default: {
                    _log.error("Received unknown packet: " + Integer.toHexString(id));
                    break;
                }
            }
        } else {
            switch (id) {
                case 1: {
                    packet = new OnlineStatus();
                    break;
                }
                case 2: {
                    packet = new PlayerAuthRequest();
                    break;
                }
                case 3: {
                    packet = new PlayerInGame();
                    break;
                }
                case 4: {
                    packet = new PlayerLogout();
                    break;
                }
                case 5: {
                    packet = new SetAccountInfo();
                    break;
                }
                case 7: {
                    packet = new ChangeAllowedIp();
                    break;
                }
                case 8: {
                    packet = new ChangePassword();
                    break;
                }
                case 9: {
                    packet = new ChangeAllowedHwid();
                    break;
                }
                case 16: {
                    packet = new BonusRequest();
                    break;
                }
                case 17: {
                    packet = new ChangeAccessLevel();
                    break;
                }
                case 18: {
                    packet = new ReduceAccountPoints();
                    break;
                }
                case 19: {
                    packet = new BanRequest();
                    break;
                }
                case 20: {
                    packet = new UnbanRequest();
                    break;
                }
                case 11: {
                    packet = new LockAccountIP();
                    break;
                }
                case 12: {
                    packet = new ChangePhoneNumber();
                    break;
                }
                case 255: {
                    packet = new PingResponse();
                    break;
                }
                default: {
                    _log.error("Received unknown packet: " + Integer.toHexString(id));
                }
            }
        }
        return packet;
    }
}

