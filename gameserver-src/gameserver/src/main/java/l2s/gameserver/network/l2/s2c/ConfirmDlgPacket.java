package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SysMsgContainer;

public class ConfirmDlgPacket
extends SysMsgContainer<ConfirmDlgPacket> {
    private int _time;
    private int _requestId;

    public ConfirmDlgPacket(SystemMsg msg, int time) {
        super(msg);
        this._time = time;
    }

    @Override
    protected final void writeImpl() {
        this.writeElements();
        this.writeD(this._time);
        this.writeD(this._requestId);
    }

    public void setRequestId(int requestId) {
        this._requestId = requestId;
    }
}

