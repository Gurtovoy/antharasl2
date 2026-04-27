/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ActionFailPacket
extends L2GameServerPacket {
    public static final L2GameServerPacket STATIC = new ActionFailPacket();
    private final int _castingType;

    public ActionFailPacket() {
        this._castingType = 0;
    }

    public ActionFailPacket(int castingType) {
        this._castingType = castingType;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._castingType);
    }
}

