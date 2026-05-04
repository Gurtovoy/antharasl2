package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBrExtraUserInfo
extends L2GameServerPacket {
    private int _objectId;
    private int _effect3;
    private int _lectureMark;

    public ExBrExtraUserInfo(Player cha) {
        this._objectId = cha.getObjectId();
        this._effect3 = 0;
        this._lectureMark = cha.getLectureMark();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._effect3);
        this.writeC(this._lectureMark);
    }
}

