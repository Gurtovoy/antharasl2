/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExLightingCandleEvent
extends L2GameServerPacket {
    public static final L2GameServerPacket ENABLED = new ExLightingCandleEvent(1);
    public static final L2GameServerPacket DISABLED = new ExLightingCandleEvent(0);
    private final int _value;

    public ExLightingCandleEvent(int value) {
        this._value = value;
    }

    @Override
    protected void writeImpl() {
        this.writeH(this._value);
    }
}

