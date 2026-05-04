package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Friend;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class FriendList
extends L2GameServerPacket {
    private Friend[] _friends;

    public FriendList(Player player) {
        this._friends = player.getFriendList().values();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._friends.length);
        for (Friend f : this._friends) {
            this.writeD(f.getObjectId());
            this.writeS(f.getName());
            this.writeD(f.isOnline());
            this.writeD(f.isOnline() ? f.getObjectId() : 0);
            this.writeD(f.getLevel());
            this.writeD(f.getClassId());
        }
    }
}

