package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.actor.instances.player.Friend;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class FriendStatus
extends L2GameServerPacket {
    private final Friend _friend;
    private final boolean _login;

    public FriendStatus(Friend friend, boolean login) {
        this._friend = friend;
        this._login = login;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._login);
        this.writeS(this._friend.getName());
        if (!this._login) {
            this.writeD(this._friend.getObjectId());
        }
    }
}

