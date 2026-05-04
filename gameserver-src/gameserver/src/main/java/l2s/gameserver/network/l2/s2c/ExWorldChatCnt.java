package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExWorldChatCnt
extends L2GameServerPacket {
    private final int _count;

    public ExWorldChatCnt(Player player) {
        this._count = player.getWorldChatPoints();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._count);
    }
}

