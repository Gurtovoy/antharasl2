package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExDominionChannelSet
extends L2GameServerPacket {
    public static final L2GameServerPacket ACTIVE = new ExDominionChannelSet(1);
    public static final L2GameServerPacket DEACTIVE = new ExDominionChannelSet(0);
    private int _active;

    public ExDominionChannelSet(int active) {
        this._active = active;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._active);
    }
}

