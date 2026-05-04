package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.entity.events.impl.DuelEvent;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExDuelStart
extends L2GameServerPacket {
    private int _duelType;

    public ExDuelStart(DuelEvent e) {
        this._duelType = e.getDuelType();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._duelType);
    }
}

