package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.GameTimeController;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ClientSetTimePacket
extends L2GameServerPacket {
    public static final L2GameServerPacket STATIC = new ClientSetTimePacket();

    @Override
    protected final void writeImpl() {
        this.writeD(GameTimeController.getInstance().getGameTime());
        this.writeD(6);
    }
}

