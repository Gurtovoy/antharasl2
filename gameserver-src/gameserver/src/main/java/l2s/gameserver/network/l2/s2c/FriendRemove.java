package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class FriendRemove
extends L2GameServerPacket {
    private final String _friendName;

    public FriendRemove(String name) {
        this._friendName = name;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(1);
        this.writeS(this._friendName);
    }
}

