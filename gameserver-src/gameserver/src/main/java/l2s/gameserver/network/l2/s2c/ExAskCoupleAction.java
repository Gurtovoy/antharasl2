package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAskCoupleAction
extends L2GameServerPacket {
    private int _objectId;
    private int _socialId;

    public ExAskCoupleAction(int objectId, int socialId) {
        this._objectId = objectId;
        this._socialId = socialId;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._socialId);
        this.writeD(this._objectId);
    }
}

