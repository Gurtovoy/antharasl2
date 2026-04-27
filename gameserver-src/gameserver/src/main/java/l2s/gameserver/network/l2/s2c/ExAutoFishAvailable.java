/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class ExAutoFishAvailable
extends L2GameServerPacket {
    public static final L2GameServerPacket REMOVE = new ExAutoFishAvailable(0);
    public static final L2GameServerPacket SHOW = new ExAutoFishAvailable(1);
    public static final L2GameServerPacket FISHING = new ExAutoFishAvailable(2);
    private final int _type;

    private ExAutoFishAvailable(int type) {
        this._type = type;
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._type);
    }
}

