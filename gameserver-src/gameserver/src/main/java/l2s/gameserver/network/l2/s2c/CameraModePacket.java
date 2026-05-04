package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CameraModePacket
extends L2GameServerPacket {
    public static final L2GameServerPacket EXIT = new CameraModePacket(0);
    public static final L2GameServerPacket ENTER = new CameraModePacket(1);
    private final int mode;

    private CameraModePacket(int mode) {
        this.mode = mode;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.mode);
    }
}

