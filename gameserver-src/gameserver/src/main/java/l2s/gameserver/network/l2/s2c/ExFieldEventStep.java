/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFieldEventStep
extends L2GameServerPacket {
    private final int _own;
    private final int _cumulative;
    private final int _max;

    public ExFieldEventStep(int own, int cumulative, int max) {
        this._own = own;
        this._cumulative = cumulative;
        this._max = max;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._own);
        this.writeD(this._cumulative);
        this.writeD(this._max);
    }
}

