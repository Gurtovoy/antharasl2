package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExCallToChangeClass
extends L2GameServerPacket {
    private int _classId;
    private boolean _showMsg;

    public ExCallToChangeClass(int classId, boolean showMsg) {
        this._classId = classId;
        this._showMsg = showMsg;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._classId);
        this.writeD(this._showMsg);
    }
}

