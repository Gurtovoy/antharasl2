package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PetStatusShowPacket
extends L2GameServerPacket {
    private int _summonType;
    private int _summonObjId;

    public PetStatusShowPacket(Servitor summon) {
        this._summonType = summon.getServitorType();
        this._summonObjId = summon.getObjectId();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._summonType);
        this.writeD(this._summonObjId);
    }
}

