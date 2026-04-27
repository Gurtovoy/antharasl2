/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.TimeStamp;

public class ExUseSharedGroupItem
extends L2GameServerPacket {
    private int _itemId;
    private int _grpId;
    private int _remainedTime;
    private int _totalTime;

    public ExUseSharedGroupItem(int grpId, TimeStamp timeStamp) {
        this._grpId = grpId;
        this._itemId = timeStamp.getId();
        this._remainedTime = (int)(timeStamp.getReuseCurrent() / 1000L);
        this._totalTime = (int)(timeStamp.getReuseBasic() / 1000L);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._itemId);
        this.writeD(this._grpId);
        this.writeD(this._remainedTime);
        this.writeD(this._totalTime);
    }
}

