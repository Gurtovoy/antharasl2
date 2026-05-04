package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class SetSummonRemainTimePacket
extends L2GameServerPacket {
    private final int _maxFed;
    private final int _curFed;

    public SetSummonRemainTimePacket(Servitor summon) {
        this._curFed = summon.getCurrentFed();
        this._maxFed = summon.getMaxFed();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._maxFed);
        this.writeD(this._curFed);
    }
}

