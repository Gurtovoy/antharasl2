package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import org.napile.primitive.maps.IntObjectMap;

public class ExReceiveShowPostFriend
extends L2GameServerPacket {
    private IntObjectMap<String> _list;

    public ExReceiveShowPostFriend(Player player) {
        this._list = player.getPostFriends();
    }

    @Override
    public void writeImpl() {
        this.writeD(this._list.size());
        for (String t : this._list.valueCollection()) {
            this.writeS(t);
        }
    }
}

