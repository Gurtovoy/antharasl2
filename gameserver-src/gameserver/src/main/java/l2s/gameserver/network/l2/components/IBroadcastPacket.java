package l2s.gameserver.network.l2.components;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public interface IBroadcastPacket {
    public L2GameServerPacket packet(Player var1);
}

