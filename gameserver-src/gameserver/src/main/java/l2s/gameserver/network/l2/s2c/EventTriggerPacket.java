package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class EventTriggerPacket
extends L2GameServerPacket {
    private final int _trapId;
    private final boolean _active;

    public EventTriggerPacket(int trapId, boolean active) {
        this._trapId = trapId;
        this._active = active;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._trapId);
        this.writeC(this._active ? 1 : 0);
    }
}

