/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class L2FriendStatus
extends L2GameServerPacket {
    private String _charName;
    private boolean _login;

    public L2FriendStatus(Player player, boolean login) {
        this._login = login;
        this._charName = player.getName();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._login ? 1 : 0);
        this.writeS(this._charName);
        this.writeD(0);
    }
}

