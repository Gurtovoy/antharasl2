package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.ResidenceSide;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExCastleState
extends L2GameServerPacket {
    private final int _id;
    private final ResidenceSide _side;

    public ExCastleState(Castle castle) {
        this._id = castle.getId();
        this._side = castle.getResidenceSide();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._id);
        this.writeD(this._side.ordinal());
    }
}

