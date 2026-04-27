/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.authcomm.as2gs;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExShowScreenMessage;

public class ChangePasswordResponse
extends ReceivablePacket {
    public String _account;
    public boolean _changed;

    @Override
    protected boolean readImpl() {
        this._account = this.readS();
        this._changed = this.readD() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        GameClient client = AuthServerCommunication.getInstance().getAuthedClient(this._account);
        if (client == null) {
            return;
        }
        Player activeChar = client.getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._changed) {
            activeChar.sendPacket((IBroadcastPacket)new ExShowScreenMessage(new CustomMessage("scripts.commands.user.password.ResultTrue").toString(activeChar), 3000, ExShowScreenMessage.ScreenMessageAlign.BOTTOM_CENTER, true));
        } else {
            activeChar.sendPacket((IBroadcastPacket)new ExShowScreenMessage(new CustomMessage("scripts.commands.user.password.ResultFalse").toString(activeChar), 3000, ExShowScreenMessage.ScreenMessageAlign.BOTTOM_CENTER, true));
        }
    }
}

