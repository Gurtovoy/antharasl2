package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExUISettingPacket;

public class RequestSaveKeyMapping
extends L2GameClientPacket {
    private byte[] _data;

    @Override
    protected boolean readImpl() {
        int length = this.readD();
        if (length > this._buf.remaining() || length > Short.MAX_VALUE || length < 0) {
            this._data = null;
            return false;
        }
        this._data = new byte[length];
        this.readB(this._data);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._data == null) {
            return;
        }
        activeChar.setKeyBindings(this._data);
        activeChar.sendPacket((IBroadcastPacket)new ExUISettingPacket(activeChar));
    }
}

