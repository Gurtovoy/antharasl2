package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ValidateLocationPacket
extends L2GameServerPacket {
    private int _chaObjId;
    private Location _loc;

    public ValidateLocationPacket(GameObject cha) {
        this._chaObjId = cha.getObjectId();
        this._loc = cha.getLoc();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._chaObjId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(this._loc.h);
        this.writeC(255);
    }
}

