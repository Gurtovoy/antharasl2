/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.authcomm.as2gs;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ServerCloseSocketPacket;

public class KickPlayer
extends ReceivablePacket {
    String account;

    @Override
    public boolean readImpl() {
        this.account = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        GameClient client = AuthServerCommunication.getInstance().removeWaitingClient(this.account);
        if (client == null) {
            client = AuthServerCommunication.getInstance().removeAuthedClient(this.account);
        }
        if (client == null) {
            return;
        }
        Player activeChar = client.getActiveChar();
        if (activeChar != null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ANOTHER_PERSON_HAS_LOGGED_IN_WITH_THE_SAME_ACCOUNT);
            activeChar.kick();
        } else {
            client.close(ServerCloseSocketPacket.STATIC);
        }
    }
}

