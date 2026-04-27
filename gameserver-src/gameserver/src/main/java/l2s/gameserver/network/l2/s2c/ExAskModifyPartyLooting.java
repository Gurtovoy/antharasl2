/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAskModifyPartyLooting
extends L2GameServerPacket {
    private String _requestor;
    private int _mode;

    public ExAskModifyPartyLooting(String name, int mode) {
        this._requestor = name;
        this._mode = mode;
    }

    @Override
    protected void writeImpl() {
        this.writeS(this._requestor);
        this.writeD(this._mode);
    }
}

